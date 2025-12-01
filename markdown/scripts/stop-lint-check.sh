#!/bin/bash
# Stop hook: Auto-lint markdown files before completion
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Only run if CLAUDE_PLUGIN_ROOT is set to this plugin
if [[ -z "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
    exit 0
fi

# Verify this is the markdown plugin
if [[ ! -f "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" ]]; then
    exit 0
fi

PLUGIN_NAME_CHECK=$(jq -r '.name // empty' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" 2>/dev/null)
if [[ "$PLUGIN_NAME_CHECK" != "$PLUGIN_NAME" ]]; then
    exit 0
fi

# Find git root
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$GIT_ROOT"

# Find all modified .md files (Added, Modified, Renamed, Copied)
IFS=$'\n' read -r -d '' -a modified_files < <(
    git diff --name-only --diff-filter=AMRC 2>/dev/null | grep '\.md$' && printf '\0'
) || true

if [[ ${#modified_files[@]} -eq 0 ]]; then
    echo "No modified markdown files to lint." >&2
    exit 0
fi

echo "Linting ${#modified_files[@]} modified markdown file(s)..." >&2

# Format with prettier first
for file in "${modified_files[@]}"; do
    if [[ -f "$file" ]]; then
        prettier --write "$file" --prose-wrap always 2>&1 || true
    fi
done

# Run markdownlint with auto-fix
for file in "${modified_files[@]}"; do
    if [[ -f "$file" ]]; then
        markdownlint "$file" --fix 2>&1 || true
    fi
done

# Final validation (fail if issues remain)
echo "Running final validation..." >&2
if ! markdownlint "${modified_files[@]}"; then
    echo "" >&2
    echo "ERROR: Markdown linting failed. Please fix the issues above." >&2
    exit 1
fi

echo "All markdown files validated successfully." >&2
