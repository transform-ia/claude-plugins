#!/bin/bash
# PreToolUse: Enforce Go-only file restrictions for Write/Edit operations
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

# Detect caller from transcript - only enforce for /go:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /go:* ]]; then
    exit 0  # Not from Go plugin command, allow
fi

tool=$(echo "$input" | jq -r '.tool_name // empty')

# Only check Write/Edit operations
if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0  # Allow - not a file write operation
fi

# We're in Go plugin context - enforce Go-only file restrictions
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Allow Go-related files only (NO .golangci.yaml - agent cannot modify linter config)
case "$file_path" in
    *.go|*/go.mod|*/go.sum)
        exit 0  # Allow
        ;;
    */.golangci.yaml|*/.golangci.yml)
        echo "BLOCKED: Go plugin cannot modify linter configuration." >&2
        echo "Discuss lint issues with the user before making config changes." >&2
        exit 2  # Block
        ;;
    *)
        echo "BLOCKED: Go plugin can only modify .go, go.mod, go.sum files." >&2
        echo "For other files, use a different agent or ask outside the Go plugin." >&2
        exit 2  # Block
        ;;
esac
