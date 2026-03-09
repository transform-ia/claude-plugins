---
description: "Check infrastructure status: /infrastructure:cmd-status [--host hostname]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.sh *)]
---

# Infrastructure Status

## Permissions

This command is READ-ONLY. It checks remote host status via SSH.

---

Check running containers and services on infrastructure hosts.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.sh $ARGUMENTS")
```
