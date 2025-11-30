#!/bin/bash
# Enforce MCP plugin can only modify .mcp.json files
set -euo pipefail

input=$(cat)

# Detect caller from transcript - only enforce for /mcp:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /mcp:* ]]; then
    exit 0  # Not from MCP plugin command, allow
fi

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
