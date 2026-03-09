#!/bin/bash
# PreToolUse: Block most Bash commands when in MCP plugin context
# Allow only: claude mcp, curl, nc, ss, lsof (for connectivity)
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)

set -euo pipefail
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in block-bash.sh" >&2; exit 2' ERR

# Source shared hook library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in MCP plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "mcp"; then
    exit 0  # Not in scope - allow
fi

if [[ -z "$COMMAND" ]]; then
    exit 0  # No command to check
fi

# Allow claude mcp commands
if [[ "$COMMAND" =~ ^claude[[:space:]]+mcp ]]; then
    exit 0
fi

# Allow rm for .mcp.json files only
if [[ "$COMMAND" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$COMMAND" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        filename=$(basename "$file")
        if [[ "$filename" == ".mcp.json" ]]; then
            continue  # Allowed
        else
            echo "BLOCKED: Can only delete .mcp.json files in MCP plugin." >&2
            echo "" >&2
            echo "Attempted to delete: $file" >&2
            echo "" >&2
            echo "To delete other files, exit the MCP plugin scope first." >&2
            exit 2
        fi
    done
    exit 0
fi

# Allow curl for endpoint testing
if [[ "$COMMAND" =~ ^curl[[:space:]] ]]; then
    exit 0
fi

# Allow nc for port testing
if [[ "$COMMAND" =~ ^nc[[:space:]] ]] || [[ "$COMMAND" =~ ^timeout[[:space:]].*nc[[:space:]] ]]; then
    exit 0
fi

# Allow ss for port checking
if [[ "$COMMAND" =~ ^ss[[:space:]] ]]; then
    exit 0
fi

# Allow lsof for port checking
if [[ "$COMMAND" =~ ^lsof[[:space:]] ]]; then
    exit 0
fi

# Allow cat for reading .mcp.json
if [[ "$COMMAND" =~ ^cat[[:space:]] ]] && [[ "$COMMAND" =~ \.mcp\.json ]]; then
    exit 0
fi

# Block everything else
echo "BLOCKED: Bash not allowed in MCP plugin context." >&2
echo "" >&2
echo "Available slash commands:" >&2
echo "  /mcp:cmd-add     - Add MCP server to .mcp.json" >&2
echo "  /mcp:cmd-list    - List configured MCP servers" >&2
echo "  /mcp:cmd-remove  - Remove MCP server from config" >&2
echo "  /mcp:cmd-test    - Test MCP server connectivity" >&2
echo "" >&2
echo "Allowed bash for testing:" >&2
echo "  - cat .mcp.json (read config)" >&2
echo "  - rm .mcp.json (remove config)" >&2
echo "  - curl (endpoint testing)" >&2
echo "  - nc (network testing)" >&2
echo "  - ss, lsof (port checking)" >&2
echo "" >&2
echo "For other operations, exit the MCP plugin scope first." >&2
exit 2
