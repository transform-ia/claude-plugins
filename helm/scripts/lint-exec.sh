#!/bin/bash
# Execute prettier + yamllint + helm lint on a chart directory
# Usage: lint-exec.sh <directory>
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /helm:lint <directory>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /helm:lint /path/to/chart" >&2
    echo "  /helm:lint ." >&2
    exit 1
fi

TARGET="$1"

if [[ ! -d "$TARGET" ]]; then
    echo "Error: $TARGET is not a directory" >&2
    exit 1
fi

if [[ ! -f "$TARGET/Chart.yaml" ]]; then
    echo "Error: $TARGET/Chart.yaml not found" >&2
    exit 1
fi

cd "$TARGET"

ERRORS=0

# Format first (prettier)
echo "=== prettier ==="
prettier --write 'Chart.yaml' 'values.yaml' 2>&1 || true
# Note: templates/ is not formatted - contains Go template syntax

# Run yamllint on Chart.yaml and values.yaml
echo ""
echo "=== yamllint ==="
if [[ -f ".yamllint.yaml" ]]; then
    yamllint -c .yamllint.yaml Chart.yaml values.yaml 2>&1 || ERRORS=1
else
    yamllint Chart.yaml values.yaml 2>&1 || ERRORS=1
fi

# Run helm lint
echo ""
echo "=== helm lint ==="
helm lint . || ERRORS=1

exit $ERRORS
