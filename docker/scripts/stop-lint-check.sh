#!/bin/bash
# Stop hook: Auto-lint Dockerfile before completion
set -euo pipefail

# Check if we're in docker plugin context (pattern match for portability)
if [[ -z "${CLAUDE_PLUGIN_ROOT:-}" ]] || [[ ! "${CLAUDE_PLUGIN_ROOT}" =~ /docker$ ]]; then
    exit 0
fi

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

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
        # Ignore DL3018 (apk version pinning) - Alpine packages change frequently
        # and pinning causes builds to fail when versions are removed from repos.
        # For production images, use dependency lock files or multi-stage builds.
        hadolint --ignore DL3018 "$file" || ERRORS=1
    fi
done

exit $ERRORS
