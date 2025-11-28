#!/bin/bash
# Execute hadolint on Dockerfile
set -euo pipefail

TARGET="${1:-Dockerfile}"

if [[ ! -f "$TARGET" ]]; then
    # Try to find Dockerfile in current or specified directory
    if [[ -d "$TARGET" ]]; then
        TARGET="$TARGET/Dockerfile"
    fi
fi

if [[ ! -f "$TARGET" ]]; then
    echo "Error: Dockerfile not found at $TARGET" >&2
    exit 1
fi

hadolint "$TARGET"
