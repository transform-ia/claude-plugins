#!/bin/bash
# Execute hadolint on Dockerfile
# Usage: lint-exec.sh <Dockerfile|directory>
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /docker:cmd-lint <Dockerfile|directory>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /docker:cmd-lint Dockerfile" >&2
    echo "  /docker:cmd-lint /path/to/project" >&2
    echo "  /docker:cmd-lint /path/to/Dockerfile.prod" >&2
    exit 1
fi

TARGET="$1"

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
