#!/bin/bash
# Sync all git repositories with their GitHub remotes
# Usage: sync-repositories.sh [directory]
#   directory: Path to scan for git repos (default: current directory)
set -euo pipefail

SANDBOX_DIR="${1:-.}"
SANDBOX_DIR="$(cd "$SANDBOX_DIR" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arrays to track results
declare -a PULLED_REPOS=()
declare -a NON_MASTER_REPOS=()
declare -a UNPUSHED_REPOS=()
declare -a NO_ADMIN_REPOS=()
declare -a NOT_GITHUB_REPOS=()
declare -a SKIPPED_REPOS=()

echo "=============================================="
echo "GitHub Repository Sync - ${SANDBOX_DIR}"
echo "=============================================="
echo ""

# Get list of orgs we have admin access to
echo -e "${BLUE}Fetching organizations with admin access...${NC}"
ADMIN_ORGS=$(gh api user/memberships/orgs --jq '.[] | select(.role == "admin") | .organization.login' 2>/dev/null || echo "")
USER_LOGIN=$(gh api user --jq '.login' 2>/dev/null || echo "")

echo "Admin orgs: ${ADMIN_ORGS:-none}"
echo "User: ${USER_LOGIN:-unknown}"
echo ""

# Function to check if we have admin access to a repo's org
has_admin_access() {
    local owner="$1"

    # Check if it's our own repo
    if [[ "$owner" == "$USER_LOGIN" ]]; then
        return 0
    fi

    # Check if owner is in our admin orgs
    if echo "$ADMIN_ORGS" | grep -qx "$owner"; then
        return 0
    fi

    # Check repo-level admin access
    if gh api "repos/$owner/$2" --jq '.permissions.admin' 2>/dev/null | grep -q "true"; then
        return 0
    fi

    return 1
}

# Function to get main branch name
get_main_branch() {
    local repo_path="$1"
    cd "$repo_path"

    # Try to get default branch from remote
    local default_branch
    default_branch=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "")

    if [[ -z "$default_branch" ]]; then
        # Fall back to checking for master or main
        if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
            echo "main"
        else
            echo "master"
        fi
    else
        echo "$default_branch"
    fi
}

# Find all git repositories (up to 3 levels deep)
mapfile -t GIT_DIRS < <(find "$SANDBOX_DIR" -maxdepth 3 -type d -name ".git" 2>/dev/null | sort)

for git_dir in "${GIT_DIRS[@]}"; do
    dir=$(dirname "$git_dir")
    repo_name=$(echo "$dir" | sed "s|^$SANDBOX_DIR/||")

    echo -e "${BLUE}Processing: ${repo_name}${NC}"
    cd "$dir"

    # Get remote URL
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")

    if [[ -z "$remote_url" ]]; then
        echo -e "  ${YELLOW}No remote configured${NC}"
        SKIPPED_REPOS+=("$repo_name|No remote origin configured")
        echo ""
        continue
    fi

    # Check if it's a GitHub repo
    if [[ ! "$remote_url" =~ github\.com ]]; then
        echo -e "  ${YELLOW}Not a GitHub repository${NC}"
        NOT_GITHUB_REPOS+=("$repo_name|$remote_url")
        echo ""
        continue
    fi

    # Extract owner/repo from URL
    owner_repo=$(echo "$remote_url" | sed -E 's|.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$|\1|')
    owner=$(echo "$owner_repo" | cut -d'/' -f1)
    repo=$(echo "$owner_repo" | cut -d'/' -f2)

    echo "  Remote: $owner_repo"

    # Check admin access
    if ! has_admin_access "$owner" "$repo"; then
        echo -e "  ${YELLOW}No admin access to $owner${NC}"
        NO_ADMIN_REPOS+=("$repo_name|$owner_repo")
        echo ""
        continue
    fi

    echo -e "  ${GREEN}Admin access confirmed${NC}"

    # Get current branch and main branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    main_branch=$(get_main_branch "$dir")

    echo "  Current branch: $current_branch (main: $main_branch)"

    # Check if not on main branch
    if [[ "$current_branch" != "$main_branch" ]]; then
        # Get info about why we're on this branch
        branch_info=""

        # Check if there are uncommitted changes
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            branch_info="has uncommitted changes"
        fi

        # Check if branch has commits ahead of main
        ahead_count=$(git rev-list --count "$main_branch..$current_branch" 2>/dev/null || echo "0")
        if [[ "$ahead_count" -gt 0 ]]; then
            branch_info="${branch_info:+$branch_info, }$ahead_count commits ahead of $main_branch"
        fi

        # Get last commit info
        last_commit=$(git log -1 --format="%h %s (%cr)" 2>/dev/null || echo "unknown")
        branch_info="${branch_info:+$branch_info, }last commit: $last_commit"

        echo -e "  ${YELLOW}Not on $main_branch branch${NC}"
        NON_MASTER_REPOS+=("$repo_name|$current_branch|$branch_info")
    fi

    # Fetch remote changes
    echo "  Fetching remote..."
    git fetch origin --quiet 2>/dev/null || {
        echo -e "  ${RED}Failed to fetch${NC}"
        SKIPPED_REPOS+=("$repo_name|Failed to fetch from remote")
        echo ""
        continue
    }

    # Check if behind remote (on current branch)
    behind_count=$(git rev-list --count "HEAD..origin/$current_branch" 2>/dev/null || echo "0")
    ahead_count=$(git rev-list --count "origin/$current_branch..HEAD" 2>/dev/null || echo "0")

    # Check for unpushed changes
    if [[ "$ahead_count" -gt 0 ]]; then
        # Get details about unpushed commits
        unpushed_info=$(git log --oneline "origin/$current_branch..HEAD" 2>/dev/null | head -5 || echo "")

        # Check for uncommitted changes too
        uncommitted=""
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            uncommitted="+ uncommitted changes"
        fi

        echo -e "  ${YELLOW}$ahead_count unpushed commit(s) $uncommitted${NC}"
        UNPUSHED_REPOS+=("$repo_name|$current_branch|$ahead_count commits|$unpushed_info")
    fi

    # Pull if behind
    if [[ "$behind_count" -gt 0 ]]; then
        echo -e "  ${BLUE}Behind by $behind_count commit(s), pulling...${NC}"

        # Check for uncommitted changes that would block pull
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            echo -e "  ${YELLOW}Cannot pull: uncommitted changes present${NC}"
            SKIPPED_REPOS+=("$repo_name|Cannot pull - uncommitted changes block merge")
        else
            if git pull --ff-only origin "$current_branch" 2>/dev/null; then
                echo -e "  ${GREEN}Pulled successfully${NC}"
                PULLED_REPOS+=("$repo_name|$current_branch|$behind_count commits")
            else
                echo -e "  ${YELLOW}Pull failed (may need merge)${NC}"
                SKIPPED_REPOS+=("$repo_name|Pull failed - may need manual merge")
            fi
        fi
    else
        echo -e "  ${GREEN}Up to date${NC}"
    fi

    echo ""
done

# ============================================
# Summary Report
# ============================================

echo ""
echo "=============================================="
echo "SYNC SUMMARY"
echo "=============================================="

# Pulled repos
if [[ ${#PULLED_REPOS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${GREEN}PULLED (${#PULLED_REPOS[@]} repos):${NC}"
    for entry in "${PULLED_REPOS[@]}"; do
        IFS='|' read -r name branch commits <<< "$entry"
        echo "  - $name ($branch): $commits"
    done
fi

# Non-master branch repos
if [[ ${#NON_MASTER_REPOS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}NOT ON MAIN BRANCH (${#NON_MASTER_REPOS[@]} repos):${NC}"
    for entry in "${NON_MASTER_REPOS[@]}"; do
        IFS='|' read -r name branch info <<< "$entry"
        echo "  - $name: on '$branch'"
        echo "    Reason: $info"
    done
fi

# Unpushed changes
if [[ ${#UNPUSHED_REPOS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}UNPUSHED LOCAL CHANGES (${#UNPUSHED_REPOS[@]} repos):${NC}"
    for entry in "${UNPUSHED_REPOS[@]}"; do
        IFS='|' read -r name branch count commits <<< "$entry"
        echo "  - $name ($branch): $count"
        if [[ -n "$commits" ]]; then
            echo "    Recent commits:"
            echo "$commits" | sed 's/^/      /'
        fi
    done
fi

# No admin access
if [[ ${#NO_ADMIN_REPOS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${BLUE}NO ADMIN ACCESS (${#NO_ADMIN_REPOS[@]} repos):${NC}"
    for entry in "${NO_ADMIN_REPOS[@]}"; do
        IFS='|' read -r name remote <<< "$entry"
        echo "  - $name: $remote"
    done
fi

# Not GitHub
if [[ ${#NOT_GITHUB_REPOS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${BLUE}NOT GITHUB (${#NOT_GITHUB_REPOS[@]} repos):${NC}"
    for entry in "${NOT_GITHUB_REPOS[@]}"; do
        IFS='|' read -r name remote <<< "$entry"
        echo "  - $name: $remote"
    done
fi

# Skipped
if [[ ${#SKIPPED_REPOS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}SKIPPED/ERRORS (${#SKIPPED_REPOS[@]} repos):${NC}"
    for entry in "${SKIPPED_REPOS[@]}"; do
        IFS='|' read -r name reason <<< "$entry"
        echo "  - $name: $reason"
    done
fi

echo ""
echo "=============================================="
echo "END OF SYNC REPORT"
echo "=============================================="
