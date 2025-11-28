#!/bin/bash
# PreToolUse: Block most Bash commands when in github plugin context
# Exception: github:builder skill needs gh CLI access
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/github"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$command" == */claude-plugins/github/scripts/* ]]; then
    exit 0
fi

# Allow gh CLI commands (needed for builder skill)
if [[ "$command" =~ ^gh[[:space:]] ]]; then
    exit 0
fi

# Provide helpful redirects
if [[ "$command" =~ ^yamllint ]]; then
    echo "BLOCKED: Use /github:lint instead of direct yamllint." >&2
    exit 2
fi

if [[ "$command" =~ ^prettier ]]; then
    echo "BLOCKED: Use /github:lint instead of direct prettier." >&2
    exit 2
fi

echo "BLOCKED: Bash not allowed in github plugin context (except gh CLI)." >&2
echo "Use /github:lint, /github:status, or exit the plugin context." >&2
exit 2
