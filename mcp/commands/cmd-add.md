---
description: "Add MCP server: /mcp:cmd-add <name> <url>"
allowed-tools: [Bash]
---

# MCP Add

## Permissions

This command can only modify: `.mcp.json`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` does not contain both name and url, respond with:
"Error: name and url required. Usage: /mcp:cmd-add <name> <url>" and STOP. Do
not proceed with any tool calls.

---

Add an MCP server to the project configuration.

**Usage**: `/mcp:cmd-add <server-name> <server-url>`

**Example**:

```text
/mcp:cmd-add context7 http://context7-mcp.claude.svc.cluster.local:3000/mcp
```

## Steps

1. Add the MCP server using Claude CLI:

   ```bash
   claude mcp add --scope project $ARGUMENTS
   ```

2. Verify the server was added:

   ```bash
   claude mcp list
   ```

3. Test connectivity (if in-cluster service):

   ```bash
   # For *.svc.cluster.local URLs
   curl -v --max-time 5 <url>
   ```

## Server Types

- **HTTP**: `http://service.namespace.svc.cluster.local:port/mcp`
- **SSE**: `http://service.namespace.svc.cluster.local:port/sse`
- **External**: `https://api.example.com/mcp`

## URL Formats

- **In-cluster**: `http://<service>.<namespace>.svc.cluster.local:<port>/mcp`
- **External HTTPS**: `https://api.example.com/mcp`
