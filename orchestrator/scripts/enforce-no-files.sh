#!/bin/bash
# PreToolUse: Block Write/Edit when in orchestrator plugin context
# Orchestrator should only detect and dispatch - not modify files
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-no-files.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /orchestrator:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /orchestrator:* ]]; then
    exit 0  # Not from orchestrator plugin command, allow
fi

tool=$(echo "$input" | jq -r '.tool_name // empty')

# Block all Write and Edit operations
if [[ "$tool" == "Write" || "$tool" == "Edit" ]]; then
    echo "BLOCKED: Orchestrator plugin cannot modify files." >&2
    echo "Orchestrator detects frameworks and dispatches to specialized plugins." >&2
    echo "Use /orchestrator:detect, then launch the appropriate plugin agent." >&2
    exit 2
fi

exit 0
