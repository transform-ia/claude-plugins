---
description: "Test MCP connectivity: /mcp:cmd-test <name-or-url>"
allowed-tools: [Bash(curl *), Bash(nc *), Bash(ss *), Bash(lsof *), Read]
---

# MCP Test

## Permissions

This command is READ-ONLY. It tests MCP server connectivity without modifying
files.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: name or url
required. Usage: /mcp:cmd-test NAME-OR-URL" and STOP. Do not proceed with any
tool calls.

---

Test connectivity to an MCP server with detailed diagnostics.

**Usage**: `/mcp:cmd-test <server-name>` or `/mcp:cmd-test <url>`

**Examples**:

```text
/mcp:cmd-test context7
/mcp:cmd-test http://localhost:3000/mcp
```

## Steps

### 1. Get server URL (if name provided)

```bash
# Read configuration
cat .mcp.json | jq -r '."<server-name>".url'
```

### 2. For Local HTTP Services

```bash
# Parse URL components
URL="<server-url>"
HOST=$(echo "$URL" | sed 's|.*://\([^:/]*\).*|\1|')
PORT=$(echo "$URL" | sed 's|.*://[^:]*:\([0-9]*\).*|\1|')

# Check if the port is listening
ss -tlnp | grep ":$PORT" || lsof -i :"$PORT"

# Test HTTP connectivity
curl -v --max-time 5 "$URL"
```

### 3. For External Services (https://\*)

```bash
# Test HTTPS connectivity
curl -v --max-time 10 "$URL"
```

### 4. Verify MCP Protocol

```bash
# Use Claude CLI to test actual MCP handshake
claude mcp list | grep "<server-name>"
```

## Common Issues

| Issue                | Cause                    | Solution                     |
| -------------------- | ------------------------ | ---------------------------- |
| Connection refused   | Service not running      | Check if process is running  |
| Port not listening   | Wrong port or not started| Verify port with ss or lsof  |
| Timeout              | Firewall or routing      | Check host and port access   |
| MCP handshake failed | Server not MCP-compatible| Verify server implementation |
