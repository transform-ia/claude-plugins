#!/bin/bash
# Execute yamllint + prettier on .github directory
# Usage: cmd-lint.sh <directory>
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /github:cmd-lint <directory>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /github:cmd-lint /path/to/repo" >&2
    echo "  /github:cmd-lint ." >&2
    exit 1
fi

TARGET="$1"

if [[ ! -d "$TARGET/.github" ]]; then
    echo "Error: $TARGET/.github directory not found" >&2
    exit 1
fi

cd "$TARGET"

ERRORS=0

# Format yaml files
echo "=== prettier ==="
prettier --write '.github/**/*.yaml' 2>&1 || true

# Lint yaml files
echo ""
echo "=== yamllint ==="
yamllint .github/ || ERRORS=1

exit $ERRORS
