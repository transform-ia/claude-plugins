#!/bin/bash
# PreToolUse: Enforce Go-only file restrictions for Write/Edit operations
# This hook runs ONLY when the Go plugin is active (plugin hooks are scoped)
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)
#
# CRITICAL: Any script failure MUST exit 2 to block Claude

set -euo pipefail

# Trap any error and convert to exit 2 (blocking)
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in enforce-go-files.sh" >&2; exit 2' ERR

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')

# Only check Write/Edit operations
if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0  # Allow - not a file write operation
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Allow Go-related files only
case "$file_path" in
    *.go|*/go.mod|*/go.sum)
        exit 0  # Allow
        ;;
    *)
        echo "BLOCKED: Go plugin can only modify .go, go.mod, and go.sum files" >&2
        echo "Attempted: $file_path" >&2
        echo "" >&2
        echo "Complete the Go task first, then use another agent for other file types." >&2
        exit 2  # Block
        ;;
esac
