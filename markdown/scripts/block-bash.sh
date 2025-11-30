#!/bin/bash
# PreToolUse: Block Bash commands when in markdown plugin context
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /markdown:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /markdown:* ]]; then
    exit 0  # Not from markdown plugin command, allow
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$command" == */claude-plugins/markdown/scripts/* ]]; then
    exit 0
fi

# Allow rm for markdown files only
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    # Extract file arguments (skip flags like -f, -r, -rf)
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        case "$file" in
            *.md)
                # Allowed file type
                ;;
            *)
                echo "BLOCKED: Can only delete .md files in markdown plugin." >&2
                echo "Attempted to delete: $file" >&2
                exit 2
                ;;
        esac
    done
    exit 0
fi

# Provide helpful redirect for markdownlint
if [[ "$command" =~ markdownlint ]]; then
    echo "BLOCKED: Use /markdown:lint instead of direct markdownlint." >&2
    exit 2
fi

echo "BLOCKED: Bash not allowed in markdown plugin context." >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /markdown:lint  - Run markdownlint on .md files" >&2
echo "" >&2
echo "For other operations, exit the plugin context first." >&2
exit 2
