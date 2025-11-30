#!/bin/bash
# Stop hook: Auto-lint helm chart before completion
set -euo pipefail

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/helm"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

# Get git root - fail if not in a git repo
if ! GIT_ROOT=$(git rev-parse --show-toplevel 2>&1); then
    # Not in a git repo - this is OK for the Stop hook, just exit
    echo "Not in git repository, skipping helm lint." >&2
    exit 0
fi

# Check if there's a Chart.yaml (we're in a helm chart)
if [[ ! -f "$GIT_ROOT/Chart.yaml" ]]; then
    echo "No Chart.yaml found at git root, skipping helm lint."
    exit 0
fi

# Check for modified helm files
if ! MODIFIED_FILES=$(git -C "$GIT_ROOT" diff --name-only --diff-filter=AM 2>&1 | grep -E '(Chart\.yaml|values\.yaml|templates/)'); then
    # grep returns 1 if no matches - this is OK
    if [[ $? -gt 1 ]]; then
        echo "ERROR: Failed to check for modified files" >&2
        exit 1
    fi
    MODIFIED_FILES=""
fi

if [[ -z "$MODIFIED_FILES" ]]; then
    echo "No modified helm files to lint."
    exit 0
fi

echo "Linting helm chart..."
cd "$GIT_ROOT"

ERRORS=0

# Format first
echo "=== prettier ==="
if ! prettier --write 'Chart.yaml' 'values.yaml' 2>&1; then
    echo "" >&2
    echo "ERROR: prettier formatting failed" >&2
    echo "Fix YAML syntax before completing plugin session." >&2
    ERRORS=1
fi

# Run yamllint
echo ""
echo "=== yamllint ==="
if [[ -f ".yamllint.yaml" ]]; then
    if ! yamllint -c .yamllint.yaml Chart.yaml values.yaml 2>&1; then
        echo "" >&2
        echo "yamllint found issues. Fix before completing plugin session." >&2
        ERRORS=1
    fi
else
    if ! yamllint Chart.yaml values.yaml 2>&1; then
        echo "" >&2
        echo "yamllint found issues. Fix before completing plugin session." >&2
        ERRORS=1
    fi
fi

# Run helm lint
echo ""
echo "=== helm lint ==="
if ! helm lint . 2>&1; then
    echo "" >&2
    echo "helm lint found issues. Fix before completing plugin session." >&2
    ERRORS=1
fi

# Exit with clear summary
if [[ $ERRORS -eq 1 ]]; then
    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "ERROR: Lint checks failed" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "" >&2
    echo "Fix the issues above before exiting the plugin context." >&2
    echo "" >&2
    exit 1
else
    echo "" >&2
    echo "All lint checks passed." >&2
    exit 0
fi
