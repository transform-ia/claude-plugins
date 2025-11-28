#!/bin/bash
# Stop hook: Auto-lint Dockerfile before completion
set -euo pipefail

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/docker"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "/workspace")

# Find modified Dockerfiles
MODIFIED_FILES=$(git -C "$GIT_ROOT" diff --name-only --diff-filter=AM 2>/dev/null | grep -E '^Dockerfile|/Dockerfile' || true)

if [[ -z "$MODIFIED_FILES" ]]; then
    echo "No modified Dockerfiles to lint."
    exit 0
fi

echo "Linting modified Dockerfiles..."
cd "$GIT_ROOT"

ERRORS=0
for file in $MODIFIED_FILES; do
    if [[ -f "$file" ]]; then
        echo "Checking: $file"
        hadolint "$file" || ERRORS=1
    fi
done

exit $ERRORS
