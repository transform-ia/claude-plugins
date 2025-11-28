#!/bin/bash
# PreToolUse: Enforce .github-only file restrictions for Write/Edit
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-github-files.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/github"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')

if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Allow .github directory files (.yml only - GitHub convention)
if [[ "$file_path" == */.github/* ]]; then
    case "$file_path" in
        *.yml|*.md)
            exit 0
            ;;
        *.yaml)
            echo "BLOCKED: Use .yml extension (GitHub convention), not .yaml" >&2
            exit 2
            ;;
    esac
fi

echo "BLOCKED: GitHub plugin can only modify .github/**/*.yml and .github/**/*.md files." >&2
exit 2
