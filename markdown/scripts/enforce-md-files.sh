#!/bin/bash
# PreToolUse: Enforce markdown-only file restrictions for Write/Edit
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-md-files.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/markdown"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')

if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

case "$file_path" in
    *.md|*/.markdownlint.yaml|*/.markdownlint.json)
        exit 0
        ;;
    *)
        echo "BLOCKED: Markdown plugin can only modify .md and .markdownlint.* files." >&2
        exit 2
        ;;
esac
