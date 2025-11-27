#!/bin/bash
# PostToolUse: Check if plugin script failed and tell Claude to STOP
#
# Exit codes:
#   0 = Success, continue
#   2 = BLOCKING error - tells Claude to stop

set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')
exit_code=$(echo "$input" | jq -r '.tool_result.exit_code // 0')

# Only check plugin scripts
if [[ "$command" != */claude-plugins/go/scripts/* ]]; then
    exit 0
fi

# If plugin script succeeded, continue
if [[ "$exit_code" == "0" ]]; then
    exit 0
fi

# Plugin script failed - tell Claude to STOP
echo "" >&2
echo "═══════════════════════════════════════════════════════════════" >&2
echo "STOP: Plugin command failed (exit code $exit_code)" >&2
echo "═══════════════════════════════════════════════════════════════" >&2
echo "" >&2
echo "Do NOT try to work around this error." >&2
echo "Do NOT run other Bash commands." >&2
echo "Report the error to the user and STOP." >&2
echo "" >&2
exit 2
