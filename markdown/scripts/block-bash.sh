#!/bin/bash
# PreToolUse: Block Bash commands when in markdown plugin context
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/markdown"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
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
            *.md|*/.markdownlint.yaml|*/.markdownlint.json)
                # Allowed file type
                ;;
            *)
                echo "BLOCKED: Can only delete .md and .markdownlint.* files in markdown plugin." >&2
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
echo "Use /markdown:lint or exit the plugin context." >&2
exit 2
