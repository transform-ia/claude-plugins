---
description: "Remove MCP server: /mcp:remove <name>"
allowed-tools: [Bash, Read, Edit]
---
Remove an MCP server from the project configuration.

**Usage**: `/mcp:remove <server-name>`

**Example**:
```
/mcp:remove old-server
```

## Steps

1. Read current configuration:
   ```bash
   cat /workspace/.mcp.json
   ```

2. Verify the server exists in the configuration

3. Edit `/workspace/.mcp.json` to remove the server entry

4. Verify removal:
   ```bash
   claude mcp list
   ```

## Notes

- The Claude CLI doesn't have a native `mcp remove` command
- Removal is done by editing `.mcp.json` directly
- Always verify the server exists before removal
- Check that JSON remains valid after removal
