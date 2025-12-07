---
description: "Check workflow status: /github:cmd-status [owner/repo] [limit]"
allowed-tools: [Bash]
---

# GitHub Status

## Permissions

This command is READ-ONLY. It queries GitHub Actions workflow status using the
gh CLI. No file modifications are made.

---

## Parameter Validation

**Default values:**

- `[owner/repo]`: Auto-detect from git remote
- `[limit]`: Default to 5 workflow runs

If auto-detection fails and no owner/repo provided, respond: "Error: Cannot
detect repository. Usage: /github:cmd-status [owner/repo] [limit]"

DO NOT proceed with tool calls.

---

Query GitHub Actions workflow runs using gh CLI.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.sh $ARGUMENTS")
```
