#!/bin/bash
# Block most bash commands in MCP plugin context
# Allow only: claude mcp, kubectl (for testing), curl, nc (for connectivity)
set -euo pipefail

# Check if we're in our plugin context
MY_PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/mcp"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$MY_PLUGIN_PATH" ]]; then
    exit 0  # Not in our plugin context, allow all
fi

# Read hook input
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [[ -z "$command" ]]; then
    exit 0
fi

# Allow claude mcp commands
if [[ "$command" =~ ^claude[[:space:]]+mcp ]]; then
    exit 0
fi

# Allow kubectl for connectivity testing
if [[ "$command" =~ ^kubectl[[:space:]] ]]; then
    exit 0
fi

# Allow curl for endpoint testing
if [[ "$command" =~ ^curl[[:space:]] ]]; then
    exit 0
fi

# Allow nc for port testing
if [[ "$command" =~ ^nc[[:space:]] ]] || [[ "$command" =~ ^timeout[[:space:]].*nc[[:space:]] ]]; then
    exit 0
fi

# Allow nslookup for DNS testing
if [[ "$command" =~ ^nslookup[[:space:]] ]]; then
    exit 0
fi

# Allow cat for reading .mcp.json
if [[ "$command" =~ ^cat[[:space:]] ]] && [[ "$command" =~ \.mcp\.json ]]; then
    exit 0
fi

# Block everything else
echo "BLOCKED: MCP plugin restricts bash commands." >&2
echo "" >&2
echo "Allowed commands:" >&2
echo "  - claude mcp add/list/remove" >&2
echo "  - kubectl (for connectivity testing)" >&2
echo "  - curl (for endpoint testing)" >&2
echo "  - nc, nslookup (for network testing)" >&2
echo "" >&2
echo "Use /mcp:add, /mcp:list, /mcp:test instead." >&2
exit 2
