---
description: "Check workflow status: /github:status [owner/repo] [limit]"
allowed-tools: [Bash]
---

# GitHub Status

## Permissions

This command can only modify: `.github/**/*.yaml`, `.github/**/*.md`

---

Query GitHub Actions workflow runs using gh CLI.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/status-exec.sh $ARGUMENTS")
```
