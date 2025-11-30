---
description: "Sync MCP servers to .mcp.json"
allowed-tools: [Bash]
---

# Go MCP Sync

## Permissions

This command can only modify: `*.go`, `go.mod`, `go.sum`

---

Run the sync script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/sync-go-mcp.sh")
```
