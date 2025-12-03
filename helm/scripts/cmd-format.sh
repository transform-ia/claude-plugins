#!/bin/bash
# Execute prettier on helm chart yaml files
# Usage: cmd-format.sh <directory>
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /helm:cmd-format <directory>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /helm:cmd-format /path/to/chart" >&2
    echo "  /helm:cmd-format ." >&2
    exit 1
fi

TARGET="$1"

if [[ ! -d "$TARGET" ]]; then
    echo "Error: $TARGET is not a directory" >&2
    exit 1
fi

cd "$TARGET"

# Check for Chart.yaml existence
if [[ ! -f "Chart.yaml" ]]; then
    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "ERROR: Not a Helm chart directory" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "" >&2
    echo "Chart.yaml not found in: $TARGET" >&2
    echo "" >&2
    echo "Please navigate to a Helm chart directory." >&2
    echo "" >&2
    exit 2
fi

# Check prettier availability
if ! command -v prettier >/dev/null 2>&1; then
    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "ERROR: prettier not found" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "" >&2
    echo "The Helm plugin requires prettier for YAML formatting." >&2
    echo "" >&2
    echo "To install: npm install -g prettier" >&2
    echo "" >&2
    exit 2
fi

# Format Chart.yaml and values.yaml
echo "=== Formatting YAML files ==="
if ! prettier --write 'Chart.yaml' 'values.yaml' 2>&1; then
    echo "" >&2
    echo "ERROR: prettier formatting failed" >&2
    echo "" >&2
    echo "Chart.yaml or values.yaml may contain invalid YAML syntax." >&2
    echo "Review the errors above and fix the YAML syntax." >&2
    echo "" >&2
    exit 1
fi

echo ""
echo "Formatting completed successfully."
echo ""
# Don't format templates/ - they contain Go template syntax
echo "Note: templates/ directory is not formatted (contains Go template syntax)"
