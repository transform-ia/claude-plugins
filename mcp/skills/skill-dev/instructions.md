# MCP Configuration

## Permissions

Unless specified, everything else is BLOCKED by hooks, in which cases:

- This is EXPECTED behavior for operations outside the plugin's purpose
- DO NOT suggest workarounds for intentional restrictions
- Report: "This operation is outside the mcp plugin scope."

**Exception - Report as Bug:** Only escalate to the user if you encounter:

1. Documented features that don't work as described (e.g., can't edit .mcp.json
   despite docs saying you can)
2. Hooks blocking operations that instructions explicitly say are allowed
3. Direct contradictions between different documentation files

**Examples of EXPECTED blocks (do NOT escalate):**

- Editing Go source files (out of scope for this plugin)
- Modifying configuration files other than .mcp.json
- Running infrastructure commands (not available in local dev)

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
  - `claude mcp *` - Claude MCP commands
  - `curl`, `nc` - Connectivity testing
- **SlashCommand**: | Command | Purpose | |---------|---------| |
  `/mcp:cmd-add <name> <url>` | Add MCP server | | `/mcp:cmd-remove <name>` |
  Remove MCP server | | `/mcp:cmd-list` | List servers with status | |
  `/mcp:cmd-test <name-or-url>` | Test connectivity |

### File Restrictions

Only the following file(s) can be written, edited or deleted:

- `.mcp.json`
- `*/.mcp.json`

## Out of Scope - Exit Immediately

**If the request does NOT involve allowed tools and/or files:**

1. **Immediately respond** with:

   ```text
   MCP plugin cannot handle this request - it is outside the allowed scope.

   Allowed: .mcp.json files and /mcp:* commands
   Requested: [describe what was requested]

   Use the appropriate plugin instead:
   - Go code → go:agent-dev
   - Dockerfile → docker:agent-dev
   - Helm charts → helm:agent-dev
   ```

2. **Stop execution** - do not attempt workarounds or continue
3. **Do not make any tool calls** for the out-of-scope operation
4. **Wait for user** to rephrase or switch plugins

## Configuration Format

```json
{
  "server-name": {
    "type": "http",
    "url": "http://localhost:port/mcp"
  }
}
```

## Server Types

| Type  | Description                      |
| ----- | -------------------------------- |
| http  | Standard HTTP MCP server         |
| sse   | Server-Sent Events MCP server    |
| stdio | Standard I/O (command-line tool) |

## URL Patterns

### Local Servers

```text
http://localhost:<port>/mcp
```

Example: `http://localhost:3000/mcp`

### HTTP Servers

```text
https://api.example.com/mcp
```

### stdio Servers

```json
{
  "server-name": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@example/mcp-server"]
  }
}
```

## Connectivity Requirements

### Local Services

1. Process must be running on the expected port
2. Correct port number in URL

### External Services

1. DNS resolution for external domains
2. Valid SSL certificates

## Troubleshooting

| Issue              | Check                      |
| ------------------ | -------------------------- |
| Service not found  | Check process is running   |
| Connection refused | Check URL/port             |
| Timeout            | Check firewall/process     |
| DNS failure        | Check URL/port             |

### Diagnostics

```bash
# Test connectivity
curl http://localhost:<port>/mcp

# Check if port is in use
lsof -i :<port>

# Alternative port check
ss -tlnp | grep <port>
```

## Best Practices

- Use descriptive names: `context7-docs`, `n8n-workflow`
- Test after adding: Always run `/mcp:cmd-list` to verify
- Check connectivity: Use `/mcp:cmd-test` for new servers
