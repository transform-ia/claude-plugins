#!/bin/bash
# Execute prettier on helm chart yaml files
set -euo pipefail

TARGET="${1:-.}"

if [[ ! -d "$TARGET" ]]; then
    echo "Error: $TARGET is not a directory" >&2
    exit 1
fi

cd "$TARGET"

# Format Chart.yaml and values.yaml
prettier --write 'Chart.yaml' 'values.yaml' 2>&1 || true

# Don't format templates/ - they contain Go template syntax
echo "Note: templates/ directory is not formatted (contains Go template syntax)"
