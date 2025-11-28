---
description: "Get workflow logs: /github:logs <run-id> [owner/repo]"
allowed-tools: [Bash]
---
Get logs for a GitHub Actions workflow run.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/logs-exec.sh $ARGUMENTS")
```
