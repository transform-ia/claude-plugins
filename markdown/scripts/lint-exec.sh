#!/bin/bash
# Execute markdownlint
# Usage: lint-exec.sh <path>
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /markdown:lint <path>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /markdown:lint README.md" >&2
    echo "  /markdown:lint /path/to/docs" >&2
    echo "  /markdown:lint ." >&2
    exit 1
fi

TARGET="$1"

if [[ ! -d "$TARGET" && ! -f "$TARGET" ]]; then
    echo "Error: $TARGET does not exist" >&2
    exit 1
fi

# Format with prettier first (markdown files only)
if [[ -d "$TARGET" ]]; then
    prettier --write "$TARGET/**/*.md" --prose-wrap always 2>&1 || true
elif [[ "$TARGET" == *.md ]]; then
    prettier --write "$TARGET" --prose-wrap always 2>&1 || true
fi

# Run markdownlint with config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
markdownlint "$TARGET" -c "$SCRIPT_DIR/markdownlint-config.yaml" --fix 2>&1 || true
markdownlint "$TARGET" -c "$SCRIPT_DIR/markdownlint-config.yaml"
