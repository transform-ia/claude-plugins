#!/bin/bash
# Stop hook: Auto-lint markdown files before completion
set -euo pipefail

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/markdown"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

# Find git root from current directory or use workspace
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "/workspace")

# Find all modified .md files
MODIFIED_FILES=$(git -C "$GIT_ROOT" diff --name-only --diff-filter=AM 2>/dev/null | grep '\.md$' || true)

if [[ -z "$MODIFIED_FILES" ]]; then
    echo "No modified markdown files to lint."
    exit 0
fi

echo "Linting modified markdown files..."
cd "$GIT_ROOT"

# Run markdownlint on modified files
for file in $MODIFIED_FILES; do
    if [[ -f "$file" ]]; then
        markdownlint "$file" --fix 2>&1 || true
    fi
done

# Final check
markdownlint $MODIFIED_FILES
