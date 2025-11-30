#!/bin/bash
# Stop hook: Auto-lint .github files before completion
set -euo pipefail

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/github"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "/workspace")

# Check for .github directory
if [[ ! -d "$GIT_ROOT/.github" ]]; then
    echo "No .github directory found, skipping lint."
    exit 0
fi

# Check for modified github files
MODIFIED_FILES=$(git -C "$GIT_ROOT" diff --name-only --diff-filter=AM 2>/dev/null | grep '^\.github/' || true)

if [[ -z "$MODIFIED_FILES" ]]; then
    echo "No modified .github files to lint."
    exit 0
fi

echo "Linting .github files..."
cd "$GIT_ROOT"

ERRORS=0

# Format first
echo "=== prettier ==="
prettier --write '.github/**/*.yaml' 2>&1 || true

# Lint
echo ""
echo "=== yamllint ==="
yamllint .github/ || ERRORS=1

exit $ERRORS
