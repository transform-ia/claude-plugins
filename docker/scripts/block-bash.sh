#!/bin/bash
# PreToolUse: Block Bash commands when in docker plugin context
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/docker"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
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
echo "Use /docker:lint, /docker:image-tag, or exit the plugin context." >&2
exit 2
