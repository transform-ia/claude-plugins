---
description: "Remove MCP server: /mcp:remove <name>"
allowed-tools: [Bash, Read, Edit]
---

# MCP Remove

## Permissions

This command can only modify: `.mcp.json`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: name required.
Usage: /mcp:remove <name>" and STOP. Do not proceed with any tool calls.

---

Remove an MCP server from the project configuration.

**Usage**: `/mcp:remove <server-name>`

**Example**:

```text
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
