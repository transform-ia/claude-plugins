# MCP Configuration

## Permissions

Unless specified, everything else is BLOCKED by hooks, in which cases:

- This is EXPECTED behavior
- DO NOT suggest workarounds
- Report: "This operation is outside the mcp plugin scope." Unless you think
  this is an implementation issue, in which case start a conversation with the
  human on how to fix the issue.

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Search** - Search file by name
- **Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
  - `claude mcp *` - Claude MCP commands
  - `kubectl get/describe/logs` - Read-only cluster info
  - `curl`, `nc`, `nslookup` - Connectivity testing
- **SlashCommand**: | Command | Purpose | |---------|---------| |
  `/mcp:add <name> <url>` | Add MCP server | | `/mcp:remove <name>` | Remove MCP
  server | | `/mcp:list` | List servers with status | |
  `/mcp:test <name-or-url>` | Test connectivity |

### File Restrictions

Only the following file(s) can be written, edited or deleted:

- `.mcp.json`
- `*/.mcp.json`

## Out of Scope - Bail Out Immediately

**If the request does NOT involve allowed tools and/or files, STOP and report:**

`MCP plugin can't handle request outside its scope.`

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
- Test after adding: Always run `/mcp:list` to verify
- Check connectivity: Use `/mcp:test` for new servers
