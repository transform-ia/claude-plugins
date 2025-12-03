---
description: "Sync MCP servers to .mcp.json"
allowed-tools: [Bash]
---

# Go MCP Sync

## Permissions

This command modifies `/workspace/.mcp.json` (syncs golang-chart MCP servers). Does not modify Go source files.

---

Run the sync script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-mcp-sync.sh")
```
