#!/bin/bash
# Full release workflow: version bump, commit, tag, build
# Usage: release-exec.sh [directory] <version|patch|minor|major|auto>
set -euo pipefail

# === SECTION 0: Parse Arguments ===

# Check if first argument is a directory path
FIRST_ARG="${1:-}"
SECOND_ARG="${2:-}"

if [[ -z "$FIRST_ARG" ]]; then
    echo "Usage: /github:cmd-release [directory] <version|patch|minor|major|auto>" >&2
    exit 1
fi

# If first arg is a directory, cd to it and use second arg as version
if [[ -d "$FIRST_ARG" ]]; then
    echo "Changing to directory: $FIRST_ARG"
    cd "$FIRST_ARG"
    VERSION_ARG="$SECOND_ARG"

    if [[ -z "$VERSION_ARG" ]]; then
        echo "Usage: /github:cmd-release [directory] <version|patch|minor|major|auto>" >&2
        exit 1
    fi
else
    # First arg is the version
    VERSION_ARG="$FIRST_ARG"
fi

# === SECTION 1: Repository Detection ===

REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -z "$REMOTE_URL" ]]; then
    echo "Error: Not a git repository or no remote configured" >&2
    exit 1
fi

REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$|\1|')

if [[ -z "$REPO" ]]; then
    echo "Error: Cannot detect GitHub repository from remote URL" >&2
    exit 1
fi

echo "Repository: $REPO"
echo ""

# === SECTION 2: Helper Functions ===

determine_current_version() {
    # Get latest git tag
    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    if [[ -n "$LATEST_TAG" ]]; then
        # Strip 'v' prefix if present
        echo "${LATEST_TAG#v}"
    else
        echo "0.0.0"
    fi
}

bump_version() {
    local CURRENT="$1"
    local BUMP_TYPE="$2"

    # Parse version components
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

    case "$BUMP_TYPE" in
        major)
            echo "$((MAJOR + 1)).0.0"
            ;;
        minor)
            echo "${MAJOR}.$((MINOR + 1)).0"
            ;;
        patch)
            echo "${MAJOR}.${MINOR}.$((PATCH + 1))"
            ;;
        *)
            echo "$CURRENT"
            ;;
    esac
}

detect_version_from_files() {
    # Try Chart.yaml
    if [[ -f "Chart.yaml" ]]; then
        CHART_VERSION=$(grep '^version:' Chart.yaml | awk '{print $2}' | tr -d '"' 2>/dev/null || echo "")
        if [[ -n "$CHART_VERSION" ]]; then
            echo "$CHART_VERSION"
            return 0
        fi
    fi

    # Try package.json
    if [[ -f "package.json" ]] && command -v jq >/dev/null; then
        PKG_VERSION=$(jq -r '.version // empty' package.json 2>/dev/null || echo "")
        if [[ -n "$PKG_VERSION" ]]; then
            echo "$PKG_VERSION"
            return 0
        fi
    fi

    # Try go.mod (version in tag format)
    if [[ -f "go.mod" ]]; then
        # Go modules use git tags, not file versions
        return 1
    fi

    return 1
}

detect_bump_from_commits() {
    # Check recent commits for conventional commit prefixes
    RECENT_COMMITS=$(git log --pretty=format:"%s" "$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)"..HEAD 2>/dev/null || echo "")

    if echo "$RECENT_COMMITS" | grep -qi "BREAKING CHANGE\|^feat!:"; then
        echo "major"
    elif echo "$RECENT_COMMITS" | grep -qi "^feat:"; then
        echo "minor"
    elif echo "$RECENT_COMMITS" | grep -qi "^fix:"; then
        echo "patch"
    else
        return 1
    fi
}

# === SECTION 3: Determine Target Version ===

CURRENT_VERSION=$(determine_current_version)
echo "Current version: $CURRENT_VERSION"

case "$VERSION_ARG" in
    patch|minor|major)
        TARGET_VERSION=$(bump_version "$CURRENT_VERSION" "$VERSION_ARG")
        echo "Bumping $VERSION_ARG version: $CURRENT_VERSION -> $TARGET_VERSION"
        ;;
    auto)
        # Priority 1: Detect from files
        if FILE_VERSION=$(detect_version_from_files); then
            if [[ "$FILE_VERSION" != "$CURRENT_VERSION" ]]; then
                TARGET_VERSION="$FILE_VERSION"
                echo "Using version from project files: $TARGET_VERSION"
            else
                # Priority 2: Detect from commits
                if BUMP_TYPE=$(detect_bump_from_commits); then
                    TARGET_VERSION=$(bump_version "$CURRENT_VERSION" "$BUMP_TYPE")
                    echo "Detected $BUMP_TYPE bump from commits: $TARGET_VERSION"
                else
                    # Priority 3: Ask user
                    echo "Cannot auto-detect version bump." >&2
                    echo "Current version: $CURRENT_VERSION" >&2
                    echo "Specify version explicitly or use patch/minor/major" >&2
                    exit 1
                fi
            fi
        else
            # No files, try commits
            if BUMP_TYPE=$(detect_bump_from_commits); then
                TARGET_VERSION=$(bump_version "$CURRENT_VERSION" "$BUMP_TYPE")
                echo "Detected $BUMP_TYPE bump from commits: $TARGET_VERSION"
            else
                echo "Cannot auto-detect version bump." >&2
                echo "Current version: $CURRENT_VERSION" >&2
                echo "Specify version explicitly or use patch/minor/major" >&2
                exit 1
            fi
        fi
        ;;
    *)
        # Explicit version provided
        TARGET_VERSION="${VERSION_ARG#v}"  # Strip 'v' prefix if present
        echo "Using explicit version: $TARGET_VERSION"
        ;;
esac

echo ""

# === SECTION 4: Validate Version ===

# Check if tag already exists
if git rev-parse "v${TARGET_VERSION}" >/dev/null 2>&1; then
    echo "Error: Tag v${TARGET_VERSION} already exists" >&2
    exit 1
fi

# === SECTION 5: Auto-commit Changes ===

echo "Checking for uncommitted changes..."

if ! git diff-index --quiet HEAD --; then
    echo "Found uncommitted changes. Committing all files..."

    # Generate commit message based on changes
    CHANGED_FILES=$(git diff --name-only HEAD | head -5)
    COMMIT_MSG="Release v${TARGET_VERSION}"

    # Add context based on changed files
    if echo "$CHANGED_FILES" | grep -q "Chart.yaml"; then
        COMMIT_MSG="${COMMIT_MSG}: Update Helm chart"
    elif echo "$CHANGED_FILES" | grep -q "package.json"; then
        COMMIT_MSG="${COMMIT_MSG}: Update package version"
    elif echo "$CHANGED_FILES" | grep -q "\.go$"; then
        COMMIT_MSG="${COMMIT_MSG}: Update Go modules"
    elif echo "$CHANGED_FILES" | grep -q "Dockerfile"; then
        COMMIT_MSG="${COMMIT_MSG}: Update Docker configuration"
    fi

    git add .
    git commit -m "$COMMIT_MSG"

    echo "Committed: $COMMIT_MSG"
else
    echo "No uncommitted changes."
fi

echo ""

# === SECTION 6: Create and Push Tag ===

echo "Creating tag v${TARGET_VERSION}..."
git tag "v${TARGET_VERSION}"

echo "Pushing code and tags to origin..."
git push origin HEAD --tags

echo ""

# === SECTION 7: Monitor Build ===

echo "==========================================="
echo "Monitoring GitHub Actions workflows..."
echo "==========================================="
echo ""

# Call build-exec.sh to monitor workflows
# Use same repo detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/build-exec.sh" "$REPO"

BUILD_EXIT=$?

echo ""

# === SECTION 8: Report Results ===

if [[ $BUILD_EXIT -eq 0 ]]; then
    echo "==========================================="
    echo "SUCCESS: Release v${TARGET_VERSION} complete"
    echo "==========================================="
    echo ""
    echo "Tag: v${TARGET_VERSION}"
    echo "Repository: $REPO"
    echo "All workflows passed"
    exit 0
else
    echo "==========================================" >&2
    echo "FAILED: Release v${TARGET_VERSION}" >&2
    echo "==========================================" >&2
    echo "" >&2
    echo "Tag v${TARGET_VERSION} was created and pushed" >&2
    echo "However, workflows failed" >&2
    echo "Review errors above and fix issues" >&2
    exit 1
fi
