#!/bin/bash
# Enforce MCP plugin can only modify .mcp.json files
set -euo pipefail

# Check if we're in our plugin context
MY_PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/mcp"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$MY_PLUGIN_PATH" ]]; then
    exit 0  # Not in our plugin context, allow all operations
fi

# Read hook input
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
    exit 0  # No file path, allow
fi

# MCP plugin can only modify .mcp.json files
case "$file_path" in
    *.mcp.json|*/.mcp.json)
        exit 0
        ;;
    *)
        echo "BLOCKED: MCP plugin can only modify .mcp.json files." >&2
        echo "File: $file_path" >&2
        echo "" >&2
        echo "The MCP plugin is restricted to MCP server configuration only." >&2
        exit 2
        ;;
esac
