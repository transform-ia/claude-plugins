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

# Allow .github directory files (.yaml convention)
if [[ "$file_path" == */.github/* ]]; then
    case "$file_path" in
        *.yaml|*.md)
            exit 0
            ;;
        *.yml)
            echo "BLOCKED: Use .yaml extension (not .yml) - project convention" >&2
            exit 2
            ;;
    esac
fi

echo "BLOCKED: GitHub plugin can only modify .github/**/*.yaml and .github/**/*.md files." >&2
exit 2
