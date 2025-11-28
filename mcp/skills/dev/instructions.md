# MCP Plugin Guidelines

## Purpose

The MCP plugin manages MCP (Model Context Protocol) server configurations in `/workspace/.mcp.json`.

## Available Commands

| Command | Purpose |
|---------|---------|
| `/mcp:add <name> <url>` | Add MCP server |
| `/mcp:remove <name>` | Remove MCP server |
| `/mcp:list` | List servers with status |
| `/mcp:test <name-or-url>` | Test connectivity |

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

- **http**: Standard HTTP MCP server (most common)
- **sse**: Server-Sent Events MCP server
- **stdio**: Standard input/output (command-line tools)

## URL Patterns

### In-Cluster Services

```
http://<service>.<namespace>.svc.cluster.local:<port>/mcp
```

**Example**: `http://context7-mcp.claude.svc.cluster.local:3000/mcp`

### External Services

```
https://api.example.com/mcp
```

## Connectivity Requirements

### In-Cluster Services

1. **Service must exist** in the target namespace
2. **Network policies** must allow:
   - Egress from Claude pod
   - Ingress to target service
3. **DNS resolution** must work (kube-dns)

### External Services

1. **Egress network policy** must allow HTTPS (port 443)
2. **DNS resolution** must work for external domains
3. **Valid SSL certificates** (for HTTPS)

## Troubleshooting

### Connection Failed

1. Run `/mcp:test <server-name>` for diagnostics
2. Check service exists: `kubectl get svc <name> -n <namespace>`
3. Check pods running: `kubectl get pods -n <namespace>`
4. Check network policies

### Common Issues

| Issue | Check |
|-------|-------|
| Service not found | `kubectl get svc` |
| Connection refused | Pod not running |
| Timeout | Network policy blocking |
| DNS failure | Service name/namespace |

## Best Practices

1. **Use descriptive names**: `context7-docs`, `n8n-workflow`
2. **Test after adding**: Always run `/mcp:list` to verify
3. **Check connectivity**: Use `/mcp:test` for new servers
4. **Prefer Claude CLI**: Use `claude mcp add` when possible
