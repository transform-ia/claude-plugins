---
description: "Wipe all VictoriaLogs data (destructive): /infrastructure:otel-wipe-logs"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/wipe-logs.sh *)]
---

# Wipe VictoriaLogs

## Permissions

This command is **destructive** — it deletes all log data. Confirm with the user before running.

---

## Safety Rules

1. Always confirm with the user before executing
2. This stops the victorialogs container, wipes the data volume, and restarts it
3. All historical log data will be permanently lost

---

Wipe all VictoriaLogs data using the plugin script.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/wipe-logs.sh")
```
