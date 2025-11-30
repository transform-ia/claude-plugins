#!/bin/bash
# PreToolUse: Enforce markdown-only file restrictions for Write/Edit
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-md-files.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /markdown:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /markdown:* ]]; then
    exit 0  # Not from markdown plugin command, allow
fi

tool=$(echo "$input" | jq -r '.tool_name // empty')

if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

case "$file_path" in
    *.md)
        exit 0
        ;;
    *)
        echo "BLOCKED: Markdown plugin can only modify *.md files." >&2
        exit 2
        ;;
esac
