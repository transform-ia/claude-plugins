#!/bin/bash
# PreToolUse: Block Bash commands when in docker plugin context
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /docker:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /docker:* ]]; then
    exit 0  # Not from docker plugin command, allow
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$command" == */claude-plugins/docker/scripts/* ]]; then
    exit 0
fi

# Allow rm for docker files only
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        filename=$(basename "$file")
        case "$filename" in
            Dockerfile|Dockerfile.*|.dockerignore)
                # Allowed file type
                ;;
            *)
                echo "BLOCKED: Can only delete Dockerfile and .dockerignore in docker plugin." >&2
                echo "Attempted to delete: $file" >&2
                exit 2
                ;;
        esac
    done
    exit 0
fi

# Provide helpful redirects
if [[ "$command" =~ hadolint ]]; then
    echo "BLOCKED: Use /docker:lint instead of direct hadolint." >&2
    exit 2
fi

if [[ "$command" =~ ^docker ]]; then
    echo "BLOCKED: Docker commands not allowed. Use /docker:lint or /docker:image-tag." >&2
    exit 2
fi

echo "BLOCKED: Bash not allowed in docker plugin context." >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /docker:lint        - Run hadolint on Dockerfile" >&2
echo "  /docker:image-tag   - Query image tags from registry" >&2
echo "" >&2
echo "For other operations, exit the plugin context first." >&2
exit 2
