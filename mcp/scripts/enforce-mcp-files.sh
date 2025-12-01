#!/bin/bash
# PreToolUse: Enforce MCP plugin can only modify .mcp.json files
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)
#
# CRITICAL: Any script failure MUST exit 2 to block Claude

set -euo pipefail

# Trap any error and convert to exit 2 (blocking)
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in enforce-mcp-files.sh" >&2; exit 2' ERR

# Source shared hook library
source "/workspace/sandbox/transform-ia/claude-plugins/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in MCP plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "mcp"; then
    exit 0  # Not in scope - allow
fi

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0  # Allow - not a file write operation
fi

if [[ -z "$FILE_PATH" ]]; then
    exit 0  # No file path, allow
fi

# Normalize path to prevent traversal attacks
normalized_path=$(normalize_path "$FILE_PATH")

# MCP plugin can only modify .mcp.json files
case "$normalized_path" in
    *.mcp.json|*/.mcp.json)
        exit 0  # Allow
        ;;
    *)
        echo "BLOCKED: MCP plugin can only modify .mcp.json files." >&2
        echo "" >&2
        echo "Attempted to modify: $FILE_PATH" >&2
        echo "" >&2
        echo "The MCP plugin is restricted to MCP server configuration only." >&2
        echo "" >&2
        echo "For other file types:" >&2
        echo "  - Go files (*.go) → use go:skill-dev" >&2
        echo "  - Dockerfile → use docker:skill-dev" >&2
        echo "  - Helm charts (*.yaml) → use helm:skill-dev" >&2
        echo "  - GitHub workflows → use github:skill-dev" >&2
        echo "  - Other files → exit MCP plugin scope first" >&2
        exit 2  # Block
        ;;
esac
