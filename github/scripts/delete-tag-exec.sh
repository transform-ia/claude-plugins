#!/bin/bash
# Delete a git tag locally, remotely, and clean up artifacts
# Usage: delete-tag-exec.sh <tag> [directory]
set -euo pipefail

# === SECTION 0: Parse Arguments ===

TAG="${1:-}"
DIRECTORY="${2:-.}"

if [[ -z "$TAG" ]]; then
    echo "Usage: /github:cmd-delete-tag <tag> [directory]" >&2
    exit 1
fi

# Normalize tag (ensure 'v' prefix)
if [[ ! "$TAG" =~ ^v ]]; then
    TAG="v${TAG}"
fi

# Extract version without 'v' prefix for artifacts
VERSION="${TAG#v}"

# === SECTION 1: Change Directory ===

if [[ "$DIRECTORY" != "." ]]; then
    echo "Changing to directory: $DIRECTORY"
    cd "$DIRECTORY"
fi

# === SECTION 2: Repository Detection ===

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

# Extract org/owner from repo
ORG="${REPO%%/*}"
REPO_NAME="${REPO##*/}"

echo "Repository: $REPO"
echo "Tag: $TAG"
echo ""

# === SECTION 3: Tag Validation ===

# Check if tag exists locally
LOCAL_TAG_EXISTS=false
if git tag -l "$TAG" | grep -q "^${TAG}$"; then
    LOCAL_TAG_EXISTS=true
fi

# Check if tag exists remotely
REMOTE_TAG_EXISTS=false
if git ls-remote --tags origin | grep -q "refs/tags/${TAG}$"; then
    REMOTE_TAG_EXISTS=true
fi

if [[ "$LOCAL_TAG_EXISTS" == "false" ]] && [[ "$REMOTE_TAG_EXISTS" == "false" ]]; then
    echo "Warning: Tag $TAG does not exist locally or remotely"
    exit 0
fi

# === SECTION 4: Delete Tag ===

echo "Deleting tag $TAG..."
echo ""

# Delete remote tag first (safer order)
if [[ "$REMOTE_TAG_EXISTS" == "true" ]]; then
    echo "Deleting remote tag..."
    git push --delete origin "$TAG"
    echo "✓ Remote tag deleted"
else
    echo "⊘ Remote tag does not exist, skipping"
fi

# Delete local tag
if [[ "$LOCAL_TAG_EXISTS" == "true" ]]; then
    echo "Deleting local tag..."
    git tag -d "$TAG"
    echo "✓ Local tag deleted"
else
    echo "⊘ Local tag does not exist, skipping"
fi

# Delete GitHub release (best effort, may not exist)
echo "Checking for GitHub release..."
if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
    echo "Deleting GitHub release..."
    gh release delete "$TAG" --repo "$REPO" --yes
    echo "✓ GitHub release deleted"
else
    echo "⊘ No GitHub release found, skipping"
fi

echo ""

# === SECTION 5: Detect Project Type ===

PROJECT_TYPE="generic"

if [[ -f "Dockerfile" ]]; then
    PROJECT_TYPE="docker"
    PACKAGE_TYPE="container"
    PACKAGE_NAME="$REPO_NAME"
elif [[ -f "Chart.yaml" ]]; then
    PROJECT_TYPE="helm"
    PACKAGE_TYPE="container"
    # Extract chart name from Chart.yaml
    PACKAGE_NAME=$(grep '^name:' Chart.yaml | awk '{print $2}' | tr -d '"' || echo "$REPO_NAME")
fi

echo "Project type: $PROJECT_TYPE"

# === SECTION 6: Delete Artifacts ===

if [[ "$PROJECT_TYPE" == "docker" ]] || [[ "$PROJECT_TYPE" == "helm" ]]; then
    echo "Checking for artifacts in GitHub Container Registry..."
    echo ""

    # Find version ID
    VERSION_ID=$(gh api "/orgs/${ORG}/packages/${PACKAGE_TYPE}/${PACKAGE_NAME}/versions" \
        --jq ".[] | select(.metadata.container.tags[]? == \"${VERSION}\") | .id" 2>/dev/null || echo "")

    if [[ -n "$VERSION_ID" ]]; then
        echo "Found artifact version ID: $VERSION_ID"
        echo "Deleting artifact from GHCR..."

        gh api --method DELETE "/orgs/${ORG}/packages/${PACKAGE_TYPE}/${PACKAGE_NAME}/versions/${VERSION_ID}"

        echo "✓ Artifact deleted (${PACKAGE_TYPE}/${PACKAGE_NAME}:${VERSION})"
    else
        echo "⊘ No artifact found in GHCR (may have been already deleted)"
    fi
else
    echo "ℹ  No artifacts to delete (not a Docker or Helm project)"
fi

echo ""

# === SECTION 7: Summary ===

echo "==========================================="
echo "Tag deletion complete"
echo "==========================================="
echo ""
echo "Tag: $TAG"
echo "Repository: $REPO"
if [[ "$PROJECT_TYPE" == "docker" ]] || [[ "$PROJECT_TYPE" == "helm" ]]; then
    echo "Artifacts: Cleaned up"
fi
