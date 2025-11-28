#!/bin/bash
# Query image tags from Docker Hub or GHCR
# Usage: image-tag-exec.sh <image> [count]
set -euo pipefail

IMAGE="${1:-}"
COUNT="${2:-10}"

if [[ -z "$IMAGE" ]]; then
    echo "Usage: /docker:image-tag <image> [count]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /docker:image-tag python              # Docker Hub official" >&2
    echo "  /docker:image-tag alpine/kubectl      # Docker Hub user/org" >&2
    echo "  /docker:image-tag ghcr.io/org/pkg     # GitHub Container Registry" >&2
    exit 1
fi

# Parse image reference
if [[ "$IMAGE" == ghcr.io/* ]]; then
    # GHCR image: ghcr.io/org/package or ghcr.io/user/package
    REGISTRY="ghcr"
    # Remove ghcr.io/ prefix
    IMAGE_PATH="${IMAGE#ghcr.io/}"
    # Split into org/user and package
    ORG=$(echo "$IMAGE_PATH" | cut -d'/' -f1)
    PKG=$(echo "$IMAGE_PATH" | cut -d'/' -f2-)

    echo "Querying GHCR: $ORG/$PKG"
    echo "---"

    # Try as org first, fallback to user
    RESULT=$(gh api \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/orgs/$ORG/packages/container/$PKG/versions" \
        --jq ".[0:$COUNT] | .[] | .metadata.container.tags[0]" 2>/dev/null) || \
    RESULT=$(gh api \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/users/$ORG/packages/container/$PKG/versions" \
        --jq ".[0:$COUNT] | .[] | .metadata.container.tags[0]" 2>/dev/null) || \
    { echo "Error: Could not query GHCR for $ORG/$PKG" >&2; exit 1; }

    echo "$RESULT"
else
    # Docker Hub image
    REGISTRY="dockerhub"

    # Check if it's an official image (no /) or user/org image
    if [[ "$IMAGE" == */* ]]; then
        NAMESPACE=$(echo "$IMAGE" | cut -d'/' -f1)
        REPOSITORY=$(echo "$IMAGE" | cut -d'/' -f2)
    else
        NAMESPACE="library"
        REPOSITORY="$IMAGE"
    fi

    echo "Querying Docker Hub: $NAMESPACE/$REPOSITORY"
    echo "---"
    echo "Use MCP tool: mcp__dockerhub__listRepositoryTags"
    echo "  namespace: $NAMESPACE"
    echo "  repository: $REPOSITORY"
    echo "  page_size: $COUNT"
    echo ""
    echo "Or use the built-in Docker Hub MCP integration."
fi
