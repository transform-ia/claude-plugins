#!/bin/bash
# PreToolUse: Block Write/Edit when in Orchestrator plugin context
# Orchestrator should only detect and dispatch - not modify files
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)
#
# CRITICAL: Any script failure MUST exit 2 to block Claude

set -euo pipefail

# Trap any error and convert to exit 2 (blocking)
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in enforce-no-files.sh" >&2; exit 2' ERR

# Source shared hook library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in Orchestrator plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "orchestrator"; then
    exit 0  # Not in scope - allow
fi

# Block all Write and Edit operations
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
    echo "BLOCKED: Orchestrator plugin cannot modify files." >&2
    echo "" >&2
    echo "The Orchestrator plugin only detects frameworks and dispatches to specialized plugins." >&2
    echo "" >&2
    echo "Use /orchestrator:cmd-detect, then launch the appropriate plugin agent:" >&2
    echo "  - Go files (*.go) → use go:skill-dev" >&2
    echo "  - Dockerfile → use docker:skill-dev" >&2
    echo "  - Helm charts (*.yaml) → use helm:skill-dev" >&2
    echo "  - GitHub workflows → use github:skill-dev" >&2
    echo "  - Markdown (*.md) → use markdown:skill-dev" >&2
    exit 2  # Block
fi

exit 0  # Allow other operations
