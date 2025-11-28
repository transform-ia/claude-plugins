---
description: "Check workflow status: /github:status [owner/repo] [limit]"
allowed-tools: [Bash]
---
Query GitHub Actions workflow runs using gh CLI.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/status-exec.sh $ARGUMENTS")
```
