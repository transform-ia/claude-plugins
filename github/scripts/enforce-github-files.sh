#!/bin/bash
# PreToolUse: Enforce .github-only file restrictions for Write/Edit operations
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error

set -euo pipefail
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in enforce-github-files.sh" >&2; exit 2' ERR

# Only run within the github plugin context
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_ROOT" ]]; then
    exit 0
fi

# Parse hook input
input=$(cat)
TOOL_NAME=$(echo "$input" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0
fi

# Normalize path to prevent traversal attacks
normalized_path=$(readlink -m "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")

# Only allow specific files (exact match or pattern)
allowed_files=(
    ".github/dependabot.yaml"
    ".github/workflows/ci.yaml"
)
# Pattern: .github/PULL_REQUEST_TEMPLATE/*.md
allowed_pattern=".github/PULL_REQUEST_TEMPLATE/*.md"

# Extract relative path (last components matching .github/...)
relative_path=""
if [[ "$normalized_path" == */.github/* ]]; then
    relative_path=".github/${normalized_path##*/.github/}"
fi

# Check exact matches
for allowed in "${allowed_files[@]}"; do
    if [[ "$relative_path" == "$allowed" ]]; then
        exit 0
    fi
done

# Check pattern match for PULL_REQUEST_TEMPLATE/*.md
# shellcheck disable=SC2053
if [[ "$relative_path" == $allowed_pattern ]]; then
    exit 0
fi

echo "BLOCKED: GitHub plugin can only modify:" >&2
echo "  - ${allowed_files[*]}" >&2
echo "  - $allowed_pattern" >&2
echo "" >&2
echo "Attempted to modify: $FILE_PATH" >&2
echo "" >&2
echo "For other file types:" >&2
echo "  - Go files (*.go) → use go:gocode" >&2
echo "  - Dockerfile → use docker:container" >&2
echo "  - Helm charts (*.yaml) → use helm:agent-dev" >&2
echo "  - Other files → exit GitHub plugin scope first" >&2
exit 2
