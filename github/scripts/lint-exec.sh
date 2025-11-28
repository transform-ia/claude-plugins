#!/bin/bash
# Execute yamllint + prettier on .github directory
set -euo pipefail

TARGET="${1:-.}"

if [[ ! -d "$TARGET/.github" ]]; then
    echo "Error: $TARGET/.github directory not found" >&2
    exit 1
fi

cd "$TARGET"

ERRORS=0

# Format yaml files
echo "=== prettier ==="
prettier --write '.github/**/*.yaml' '.github/**/*.yml' 2>&1 || true

# Lint yaml files
echo ""
echo "=== yamllint ==="
yamllint .github/ || ERRORS=1

exit $ERRORS
