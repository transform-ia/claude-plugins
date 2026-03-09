#!/bin/bash
# PreToolUse: Block most Bash commands when in Orchestrator plugin context
# Orchestrator should only detect and dispatch - not implement
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

# Check if in Orchestrator plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "orchestrator"; then
    exit 0  # Not in scope - allow
fi

# Allow plugin's own scripts (absolute path, no cd)
if [[ "$COMMAND" == */claude-plugins/orchestrator/scripts/* ]]; then
    exit 0
fi

# Block file operations - orchestrator dispatches, doesn't implement
if [[ "$COMMAND" =~ ^(cat|head|tail|less|more)[[:space:]] ]]; then
    echo "BLOCKED: Orchestrator dispatches to plugins, doesn't read file contents." >&2
    echo "Use /orchestrator:cmd-detect to find frameworks, then dispatch to plugins." >&2
    exit 2
fi

# Block write operations
if [[ "$COMMAND" =~ ^(echo|printf|tee)[[:space:]].*\> ]]; then
    echo "BLOCKED: Orchestrator cannot write files." >&2
    exit 2
fi

# Block git operations - leave to specific plugins
if [[ "$COMMAND" =~ ^git[[:space:]] ]]; then
    echo "BLOCKED: Orchestrator cannot run git commands." >&2
    echo "Dispatch to the appropriate plugin for git operations." >&2
    exit 2
fi

# Block all other bash - orchestrator only detects and dispatches
echo "BLOCKED: Bash not allowed in Orchestrator plugin context." >&2
echo "" >&2
echo "The Orchestrator plugin only detects and dispatches to specialized plugins." >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /orchestrator:cmd-detect  - Detect frameworks in directory" >&2
echo "" >&2
echo "Use /orchestrator:cmd-detect to find frameworks, then launch the appropriate plugin agents." >&2
exit 2
