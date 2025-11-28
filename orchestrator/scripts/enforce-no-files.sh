#!/bin/bash
# PreToolUse: Block Write/Edit when in orchestrator plugin context
# Orchestrator should only detect and dispatch - not modify files
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-no-files.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/orchestrator"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')

# Block all Write and Edit operations
if [[ "$tool" == "Write" || "$tool" == "Edit" ]]; then
    echo "BLOCKED: Orchestrator plugin cannot modify files." >&2
    echo "Orchestrator detects frameworks and dispatches to specialized plugins." >&2
    echo "Use /orchestrator:detect, then launch the appropriate plugin agent." >&2
    exit 2
fi

exit 0
