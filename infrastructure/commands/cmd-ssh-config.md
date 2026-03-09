---
description: "Sync SSH config from inventory: /infrastructure:cmd-ssh-config [--dry-run]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-ssh-config.sh *)]
---

# SSH Config Sync

## Permissions

This command writes to `~/.ssh/config`. It manages a clearly delimited block
and does not touch entries outside that block.

Use `--dry-run` to preview changes without writing.

---

Sync Ansible inventory hosts into `~/.ssh/config` so Claude can SSH into them directly by hostname.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-ssh-config.sh $ARGUMENTS")
```
