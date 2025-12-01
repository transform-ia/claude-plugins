#!/bin/bash
# PreToolUse: Block Bash commands when in markdown plugin context
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/validators.sh"

input=$(cat)

# Parse hook input
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Check if in plugin scope (handles fail-closed internally)
if ! in_plugin_scope "$transcript_path" "$tool_use_id"; then
    exit 0  # Not in scope - allow
fi

# Validate bash command against allowlist
if validate_bash_command "$command"; then
    exit 0  # Allowed
else
    echo "$MSG_BLOCKED_BASH" >&2
    echo "" >&2
    echo "Allowed commands:" >&2
    printf '  - %s\n' "${ALLOWED_BASH_COMMANDS[@]}" >&2
    echo "  - ${CLAUDE_PLUGIN_ROOT}/scripts/*" >&2
    echo "" >&2
    echo "Attempted: $command" >&2
    exit 2
fi
