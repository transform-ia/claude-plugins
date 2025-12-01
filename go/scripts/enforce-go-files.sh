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

# Source shared hook library
source "/workspace/sandbox/transform-ia/claude-plugins/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in Go plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "go"; then
    exit 0  # Not in scope - allow
fi

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0  # Allow - not a file write operation
fi

# Normalize path to prevent traversal attacks
normalized_path=$(normalize_path "$FILE_PATH")

# Allow Go-related files only (NO .golangci.yaml - agent cannot modify linter config)
# Pattern matches:
#   *.go       - Any .go file at any depth
#   */go.mod   - go.mod at any depth (including ./go.mod via */go.mod or direct match)
#   */go.sum   - go.sum at any depth
case "$normalized_path" in
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
        echo "" >&2
        echo "Attempted to modify: $FILE_PATH" >&2
        echo "" >&2
        echo "For other file types:" >&2
        echo "  - Dockerfile → use docker:skill-dev" >&2
        echo "  - Helm charts (*.yaml) → use helm:skill-dev" >&2
        echo "  - Markdown (*.md) → use markdown:skill-dev" >&2
        echo "  - Other files → exit Go plugin scope first" >&2
        exit 2  # Block
        ;;
esac
