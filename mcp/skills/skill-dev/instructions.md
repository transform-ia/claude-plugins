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
- Running kubectl create/apply commands (read-only access only)

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
  - `claude mcp *` - Claude MCP commands
  - `kubectl get/describe/logs` - Read-only cluster info
  - `curl`, `nc`, `nslookup` - Connectivity testing
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

   ```
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
    "url": "http://service.namespace.svc.cluster.local:port/mcp"
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

### In-Cluster

**golang-chart services (fixed port 81):**

```text
http://<service>.<namespace>.svc.cluster.local:81/mcp
```

Example: `http://my-go-service.default.svc.cluster.local:81/mcp`

**Custom services (variable port):**

```text
http://<service>.<namespace>.svc.cluster.local:<port>/mcp
```

Example: `http://context7-mcp.claude.svc.cluster.local:3000/mcp`

### External

```text
https://api.example.com/mcp
```

## Connectivity Requirements

### In-Cluster Services

1. Service must exist in target namespace
2. Network policies must allow egress/ingress
3. DNS resolution must work (kube-dns)

### External Services

1. Egress network policy for HTTPS (port 443)
2. DNS resolution for external domains
3. Valid SSL certificates

## Troubleshooting

| Issue              | Check                   |
| ------------------ | ----------------------- |
| Service not found  | `kubectl get svc`       |
| Connection refused | Pod not running         |
| Timeout            | Network policy blocking |
| DNS failure        | Service name/namespace  |

### Diagnostics

```bash
# Test DNS
nslookup service.namespace.svc.cluster.local

# Test connectivity
nc -zv service.namespace.svc.cluster.local port

# Check service
kubectl get svc -n namespace

# Check pods
kubectl get pods -n namespace
```

## Best Practices

- Use descriptive names: `context7-docs`, `n8n-workflow`
- Test after adding: Always run `/mcp:cmd-list` to verify
- Check connectivity: Use `/mcp:cmd-test` for new servers
