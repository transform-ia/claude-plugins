---
description: "Test MCP connectivity: /mcp:test <name-or-url>"
allowed-tools: [Bash, Read]
---
Test connectivity to an MCP server with detailed diagnostics.

**Usage**: `/mcp:test <server-name>` or `/mcp:test <url>`

**Examples**:
```
/mcp:test context7
/mcp:test http://context7-mcp.claude.svc.cluster.local:3000/mcp
```

## Steps

### 1. Get server URL (if name provided)

```bash
# Read configuration
cat /workspace/.mcp.json | jq -r '."<server-name>".url'
```

### 2. For In-Cluster Services (*.svc.cluster.local)

```bash
# Parse URL components
URL="<server-url>"
SERVICE=$(echo "$URL" | sed 's|.*://\([^.]*\)\..*|\1|')
NAMESPACE=$(echo "$URL" | sed 's|.*://[^.]*\.\([^.]*\)\..*|\1|')

# Check service exists
kubectl get svc "$SERVICE" -n "$NAMESPACE"

# Check pods are running
kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/name=$SERVICE"

# Test DNS resolution
nslookup "$SERVICE.$NAMESPACE.svc.cluster.local"

# Test HTTP connectivity
curl -v --max-time 5 "$URL"

# Check network policies
kubectl get networkpolicies -n "$NAMESPACE"
kubectl get networkpolicies -n claude
```

### 3. For External Services (https://*)

```bash
# Test DNS resolution
nslookup <hostname>

# Test HTTPS connectivity
curl -v --max-time 10 "$URL"
```

### 4. Verify MCP Protocol

```bash
# Use Claude CLI to test actual MCP handshake
claude mcp list | grep "<server-name>"
```

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| DNS failure | Service doesn't exist | Check service name/namespace |
| Connection refused | Pod not running | Check pod status |
| Timeout | Network policy blocking | Check ingress/egress policies |
| MCP handshake failed | Server not MCP-compatible | Verify server implementation |
