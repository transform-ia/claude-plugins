#!/bin/bash
# Stop hook: Auto-lint helm chart before completion
set -euo pipefail

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/helm"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "/workspace")

# Check if there's a Chart.yaml (we're in a helm chart)
if [[ ! -f "$GIT_ROOT/Chart.yaml" ]]; then
    echo "No Chart.yaml found at git root, skipping helm lint."
    exit 0
fi

# Check for modified helm files
MODIFIED_FILES=$(git -C "$GIT_ROOT" diff --name-only --diff-filter=AM 2>/dev/null | grep -E '(Chart\.yaml|values\.yaml|templates/)' || true)

if [[ -z "$MODIFIED_FILES" ]]; then
    echo "No modified helm files to lint."
    exit 0
fi

echo "Linting helm chart..."
cd "$GIT_ROOT"

ERRORS=0

# Format first
echo "=== prettier ==="
prettier --write 'Chart.yaml' 'values.yaml' 2>&1 || true

# Run yamllint
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
