#!/bin/bash
# Execute helm lint + yamllint on a chart directory
set -euo pipefail

TARGET="${1:-.}"

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

# Run yamllint on Chart.yaml and values.yaml
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
