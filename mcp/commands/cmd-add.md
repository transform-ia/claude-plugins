---
description: "Add MCP server: /mcp:cmd-add <name> <url>"
allowed-tools: [Bash(claude mcp *)]
---

# MCP Add

## Permissions

This command can only modify: `.mcp.json`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` does not contain both name and url, respond with:
"Error: name and url required. Usage: /mcp:cmd-add NAME URL" and STOP. Do
not proceed with any tool calls.

---

Add an MCP server to the project configuration.

**Usage**: `/mcp:cmd-add <server-name> <server-url>`

**Example**:

```text
/mcp:cmd-add context7 http://localhost:3000/mcp
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

3. Test connectivity:

   ```bash
   curl -v --max-time 5 <url>
   ```

## Server Types

- **HTTP**: `http://localhost:port/mcp`
- **SSE**: `http://localhost:port/sse`
- **External**: `https://api.example.com/mcp`

## URL Formats

- **Local HTTP**: `http://localhost:<port>/mcp`
- **External HTTPS**: `https://api.example.com/mcp`
