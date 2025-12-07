---
description: "List MCP servers: /mcp:cmd-list"
allowed-tools: [Bash]
---

# MCP List

## Permissions

This command is READ-ONLY. It lists configured MCP servers without modifying
files.

---

List all configured MCP servers and their connection status.

**Usage**: `/mcp:cmd-list`

## Steps

1. List MCP servers with connection status:

   ```bash
   claude mcp list
   ```

2. Show raw configuration:

   ```bash
   cat /workspace/.mcp.json
   ```

## Output

The `claude mcp list` command shows:

- Server name
- Connection status (connected/failed)
- Server URL
- Server type (http/sse/stdio)

## Troubleshooting

If a server shows as failed:

1. Use `/mcp:cmd-test <server-name>` for detailed diagnostics
2. Check if the service exists (for in-cluster)
3. Verify network policies allow traffic
