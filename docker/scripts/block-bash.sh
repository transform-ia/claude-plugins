#!/bin/bash
# PreToolUse: Block Bash commands when in Docker plugin context
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)

set -euo pipefail
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in block-bash.sh" >&2; exit 2' ERR

# Source shared hook library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in Docker plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "docker"; then
    exit 0  # Not in scope - allow
fi

# Allow plugin's own scripts (absolute path, no cd)
if [[ "$COMMAND" == */claude-plugins/docker/scripts/* ]]; then
    exit 0
fi

# Allow rm for Docker files only
if [[ "$COMMAND" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$COMMAND" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        filename=$(basename "$file")
        case "$filename" in
            Dockerfile|Dockerfile.*|.dockerignore)
                # Allowed Docker file type
                ;;
            *)
                echo "BLOCKED: Can only delete Dockerfile and .dockerignore in Docker plugin." >&2
                echo "" >&2
                echo "Attempted to delete: $file" >&2
                echo "" >&2
                echo "To delete other files, exit the Docker plugin scope first." >&2
                exit 2
                ;;
        esac
    done
    exit 0
fi

# Provide helpful redirects
if [[ "$COMMAND" =~ hadolint ]]; then
    echo "BLOCKED: Use /docker:cmd-lint instead of direct hadolint." >&2
    exit 2
fi

if [[ "$COMMAND" =~ ^docker ]]; then
    echo "BLOCKED: Docker commands not allowed. Use /docker:cmd-lint or /docker:cmd-image-tag." >&2
    exit 2
fi

echo "BLOCKED: Bash not allowed in docker plugin context." >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /docker:cmd-lint        - Run hadolint on Dockerfile" >&2
echo "  /docker:cmd-image-tag   - Query image tags from registry" >&2
echo "" >&2
echo "For other operations, exit the plugin context first." >&2
exit 2
