#!/bin/bash
# PreToolUse: Enforce dockerfile-only restrictions for Write/Edit
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-docker-files.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /docker:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /docker:* ]]; then
    exit 0  # Not from docker plugin command, allow
fi

tool=$(echo "$input" | jq -r '.tool_name // empty')

if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
filename=$(basename "$file_path")

# Allow Dockerfile and .dockerignore only
case "$filename" in
    Dockerfile|Dockerfile.*|.dockerignore)
        exit 0
        ;;
    *)
        echo "BLOCKED: Docker plugin can only modify Dockerfile and .dockerignore." >&2
        exit 2
        ;;
esac
