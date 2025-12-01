#!/bin/bash
# Query image tags from Docker Hub or GHCR
# Usage: image-tag-exec.sh <image> [count]
set -euo pipefail

IMAGE="${1:-}"
COUNT="${2:-10}"

if [[ -z "$IMAGE" ]]; then
    echo "Usage: /docker:cmd-image-tag <image> [count]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /docker:cmd-image-tag python              # Docker Hub official" >&2
    echo "  /docker:cmd-image-tag alpine/kubectl      # Docker Hub user/org" >&2
    echo "  /docker:cmd-image-tag ghcr.io/org/pkg     # GitHub Container Registry" >&2
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
    # Docker Hub - bash can't call MCP tools, return error
    echo "Error: Docker Hub queries must use MCP tools directly." >&2
    echo "" >&2
    echo "This script only handles GHCR images (ghcr.io/*)." >&2
    echo "For Docker Hub, use mcp__dockerhub__listRepositoryTags tool:" >&2
    echo "  namespace: library (or org/user)" >&2
    echo "  repository: <image-name>" >&2
    echo "  page_size: 10" >&2
    exit 1
fi
