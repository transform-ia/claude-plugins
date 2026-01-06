#!/bin/bash
# Migrate repositories from main to master branch
# Usage: cmd-remove-main-branch.sh <command> [args]
#   discover [scope] - List repos with main as default
#   migrate <repo>   - Migrate a single repository
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# === SECTION 0: Parse Arguments ===

COMMAND="${1:-}"
shift || true

if [[ -z "$COMMAND" ]]; then
    echo "Usage: cmd-remove-main-branch.sh <command> [args]" >&2
    echo "Commands:" >&2
    echo "  discover [scope]  - List repos with main as default branch" >&2
    echo "  migrate <repo>    - Migrate a single repository from main to master" >&2
    exit 1
fi

# === SECTION 1: Helper Functions ===

get_user_login() {
    gh api user --jq '.login' 2>/dev/null
}

list_user_orgs() {
    gh api user/memberships/orgs --jq '.[].organization.login' 2>/dev/null || echo ""
}

list_repos_with_main() {
    local owner="$1"
    gh repo list "$owner" --limit 200 --json nameWithOwner,defaultBranchRef \
        --jq '.[] | select(.defaultBranchRef.name == "main") | .nameWithOwner' 2>/dev/null || echo ""
}

branch_exists() {
    local repo="$1"
    local branch="$2"
    local result
    result=$(gh api "repos/$repo/branches/$branch" --jq '.name' 2>/dev/null) || return 1
    # GitHub redirects master to main if master doesn't exist, so verify actual name
    [[ "$result" == "$branch" ]]
}

get_main_sha() {
    local repo="$1"
    gh api "repos/$repo/git/refs/heads/main" --jq '.object.sha' 2>/dev/null
}

compare_branches() {
    local repo="$1"
    # Compare master...main (how main differs from master)
    gh api "repos/$repo/compare/master...main" \
        --jq '{status: .status, ahead: .ahead_by, behind: .behind_by}' 2>/dev/null
}

create_branch() {
    local repo="$1"
    local branch="$2"
    local sha="$3"
    gh api "repos/$repo/git/refs" \
        -f ref="refs/heads/$branch" \
        -f sha="$sha" >/dev/null 2>&1
}

create_tag() {
    local repo="$1"
    local tag="$2"
    local sha="$3"
    gh api "repos/$repo/git/refs" \
        -f ref="refs/tags/$tag" \
        -f sha="$sha" >/dev/null 2>&1
}

merge_branches() {
    local repo="$1"
    local base="$2"
    local head="$3"
    gh api "repos/$repo/merges" \
        -f base="$base" \
        -f head="$head" \
        -f commit_message="Merge $head into $base (branch migration)" 2>&1
}

set_default_branch() {
    local repo="$1"
    local branch="$2"
    gh repo edit "$repo" --default-branch "$branch" >/dev/null 2>&1
}

delete_branch() {
    local repo="$1"
    local branch="$2"
    gh api -X DELETE "repos/$repo/git/refs/heads/$branch" >/dev/null 2>&1
}

get_open_prs_targeting() {
    local repo="$1"
    local branch="$2"
    gh pr list --repo "$repo" --base "$branch" --state open \
        --json number --jq 'length' 2>/dev/null || echo "0"
}

has_admin_access() {
    local repo="$1"
    local perms
    perms=$(gh api "repos/$repo" --jq '.permissions.admin' 2>/dev/null || echo "false")
    [[ "$perms" == "true" ]]
}

# === SECTION 2: Discover Command ===

discover_repos() {
    local scope="${1:-all}"
    local repos=()

    echo -e "${BLUE}Discovering repositories with 'main' as default branch...${NC}" >&2

    case "$scope" in
        org:*)
            # Single organization
            local org="${scope#org:}"
            echo -e "  Scope: organization '$org'" >&2
            mapfile -t repos < <(list_repos_with_main "$org")
            ;;
        */*)
            # Single repository
            echo -e "  Scope: single repository '$scope'" >&2
            local default_branch
            default_branch=$(gh repo view "$scope" --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo "")
            if [[ "$default_branch" == "main" ]]; then
                repos=("$scope")
            fi
            ;;
        "my repositories"|"personal"|"my repos")
            # User's personal repos only
            local user
            user=$(get_user_login)
            echo -e "  Scope: personal repositories for '$user'" >&2
            mapfile -t repos < <(list_repos_with_main "$user")
            ;;
        "all"|"")
            # All accessible repos (personal + orgs)
            echo -e "  Scope: all accessible repositories" >&2

            # Personal repos
            local user
            user=$(get_user_login)
            echo -e "  Checking personal repos ($user)..." >&2
            mapfile -t personal_repos < <(list_repos_with_main "$user")
            repos+=("${personal_repos[@]}")

            # Organization repos
            local orgs
            orgs=$(list_user_orgs)
            for org in $orgs; do
                echo -e "  Checking org: $org..." >&2
                mapfile -t org_repos < <(list_repos_with_main "$org")
                repos+=("${org_repos[@]}")
            done
            ;;
        *)
            echo "Unknown scope: $scope" >&2
            exit 1
            ;;
    esac

    # Filter empty entries and output
    echo ""
    echo -e "${GREEN}Found ${#repos[@]} repository(ies) with 'main' as default:${NC}" >&2

    for repo in "${repos[@]}"; do
        if [[ -n "$repo" ]]; then
            echo "$repo"
        fi
    done
}

# === SECTION 3: Migrate Command ===

migrate_repo() {
    local repo="$1"

    echo ""
    echo "=============================================="
    echo -e "${BLUE}Migrating: $repo${NC}"
    echo "=============================================="

    # Check admin access
    if ! has_admin_access "$repo"; then
        echo -e "${RED}ERROR: No admin access to $repo${NC}"
        echo "Admin access required to change default branch."
        return 1
    fi
    echo -e "${GREEN}Admin access confirmed${NC}"

    # Get main branch SHA
    local main_sha
    main_sha=$(get_main_sha "$repo")
    if [[ -z "$main_sha" ]]; then
        echo -e "${RED}ERROR: Could not get main branch SHA${NC}"
        return 1
    fi
    echo "Main branch SHA: $main_sha"

    # Create backup tag
    local backup_tag="backup-main-$(date +%Y%m%d-%H%M%S)"
    echo "Creating backup tag: $backup_tag"
    if create_tag "$repo" "$backup_tag" "$main_sha"; then
        echo -e "${GREEN}Backup tag created${NC}"
    else
        echo -e "${YELLOW}Warning: Could not create backup tag${NC}"
    fi

    # Check if master exists
    local master_exists=false
    if branch_exists "$repo" "master" >/dev/null 2>&1; then
        master_exists=true
        echo "Master branch: exists"
    else
        echo "Master branch: does not exist (will create)"
    fi

    # Handle based on whether master exists
    if [[ "$master_exists" == "true" ]]; then
        # Compare branches
        local compare_result
        compare_result=$(compare_branches "$repo")
        local status ahead behind
        status=$(echo "$compare_result" | jq -r '.status')
        ahead=$(echo "$compare_result" | jq -r '.ahead')
        behind=$(echo "$compare_result" | jq -r '.behind')

        echo "Branch comparison: status=$status, main is $ahead ahead, $behind behind"

        case "$status" in
            identical)
                echo -e "${GREEN}Branches are identical, no merge needed${NC}"
                ;;
            behind)
                echo -e "${GREEN}Master is ahead, no merge needed${NC}"
                ;;
            ahead|diverged)
                echo "Main has $ahead commit(s) not in master, merging..."
                local merge_result
                if merge_result=$(merge_branches "$repo" "master" "main" 2>&1); then
                    echo -e "${GREEN}Merge successful${NC}"
                else
                    if echo "$merge_result" | grep -q "Merge conflict"; then
                        echo -e "${RED}ERROR: Merge conflict detected${NC}"
                        echo "Manual resolution required:"
                        echo "  git clone git@github.com:$repo.git"
                        echo "  cd $(basename "$repo")"
                        echo "  git checkout master"
                        echo "  git merge main"
                        echo "  # resolve conflicts"
                        echo "  git push origin master"
                        return 1
                    else
                        echo -e "${RED}ERROR: Merge failed: $merge_result${NC}"
                        return 1
                    fi
                fi
                ;;
        esac
    else
        # Create master from main
        echo "Creating master branch from main..."
        if create_branch "$repo" "master" "$main_sha"; then
            echo -e "${GREEN}Master branch created${NC}"
        else
            echo -e "${RED}ERROR: Failed to create master branch${NC}"
            return 1
        fi
    fi

    # Change default branch
    echo "Changing default branch to master..."
    if set_default_branch "$repo" "master"; then
        echo -e "${GREEN}Default branch changed to master${NC}"
    else
        echo -e "${RED}ERROR: Failed to change default branch${NC}"
        return 1
    fi

    # Verify default branch changed
    local current_default
    current_default=$(gh repo view "$repo" --json defaultBranchRef --jq '.defaultBranchRef.name')
    if [[ "$current_default" != "master" ]]; then
        echo -e "${RED}ERROR: Default branch verification failed (got: $current_default)${NC}"
        return 1
    fi
    echo -e "${GREEN}Verified: default branch is now master${NC}"

    # Check for open PRs before deleting main
    local open_prs
    open_prs=$(get_open_prs_targeting "$repo" "main")
    if [[ "$open_prs" -gt 0 ]]; then
        echo -e "${YELLOW}Warning: $open_prs open PR(s) targeting main branch${NC}"
        echo "These PRs will need to be retargeted to master."
    fi

    # Delete main branch
    echo "Deleting main branch..."
    if delete_branch "$repo" "main"; then
        echo -e "${GREEN}Main branch deleted${NC}"
    else
        echo -e "${RED}ERROR: Failed to delete main branch${NC}"
        echo "The branch may be protected. Check branch protection settings."
        return 1
    fi

    echo ""
    echo -e "${GREEN}Migration complete for $repo${NC}"
    echo "Backup tag: $backup_tag (SHA: $main_sha)"
    echo ""
    echo "To rollback:"
    echo "  gh api repos/$repo/git/refs -f ref='refs/heads/main' -f sha='$main_sha'"
    echo "  gh repo edit $repo --default-branch main"

    return 0
}

# === SECTION 4: Main Entry Point ===

case "$COMMAND" in
    discover)
        discover_repos "${1:-all}"
        ;;
    migrate)
        if [[ -z "${1:-}" ]]; then
            echo "Usage: cmd-remove-main-branch.sh migrate <owner/repo>" >&2
            exit 1
        fi
        migrate_repo "$1"
        ;;
    *)
        echo "Unknown command: $COMMAND" >&2
        echo "Valid commands: discover, migrate" >&2
        exit 1
        ;;
esac
