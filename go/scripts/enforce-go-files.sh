#!/bin/bash
# PreToolUse: Enforce Go-only file restrictions for Write/Edit operations
# ONLY enforces when running in Go plugin context (CLAUDE_PLUGIN_ROOT set)
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

# Check if we're in Go plugin context via environment variable
# This works for both direct /go:* commands AND subagents spawned by the plugin
GO_PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/go"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$GO_PLUGIN_PATH" ]]; then
    exit 0  # Not in Go plugin context, allow all operations
fi

input=$(cat)
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
