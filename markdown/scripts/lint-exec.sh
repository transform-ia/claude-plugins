#!/bin/bash
# Execute markdownlint
set -euo pipefail

TARGET="${1:-.}"

if [[ ! -d "$TARGET" && ! -f "$TARGET" ]]; then
    echo "Error: $TARGET does not exist" >&2
    exit 1
fi

# Run markdownlint
markdownlint "$TARGET" --fix 2>&1 || true
markdownlint "$TARGET"
