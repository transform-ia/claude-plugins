#!/bin/bash
# PreToolUse: Block most Bash commands when in orchestrator plugin context
# Orchestrator should only detect and dispatch - not implement
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/orchestrator"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$command" == */claude-plugins/orchestrator/scripts/* ]]; then
    exit 0
fi

# Allow task for listing
if [[ "$command" =~ ^task[[:space:]]+(--list|-l) ]]; then
    exit 0
fi

# Block file operations - orchestrator dispatches, doesn't implement
if [[ "$command" =~ ^(cat|head|tail|less|more)[[:space:]] ]]; then
    echo "BLOCKED: Orchestrator dispatches to plugins, doesn't read file contents." >&2
    echo "Use /orchestrator:detect to find frameworks, then dispatch to plugins." >&2
    exit 2
fi

# Block write operations
if [[ "$command" =~ ^(echo|printf|tee)[[:space:]].*\> ]]; then
    echo "BLOCKED: Orchestrator cannot write files." >&2
    exit 2
fi

# Block git operations - leave to specific plugins
if [[ "$command" =~ ^git[[:space:]] ]]; then
    echo "BLOCKED: Orchestrator cannot run git commands." >&2
    echo "Dispatch to the appropriate plugin for git operations." >&2
    exit 2
fi

# Block all other bash - orchestrator only detects and dispatches
echo "BLOCKED: Orchestrator plugin only detects and dispatches." >&2
echo "Use /orchestrator:detect to find frameworks, then launch plugin agents." >&2
exit 2
