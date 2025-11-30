---
description: "Get workflow logs: /github:logs <run-id> [owner/repo]"
allowed-tools: [Bash]
---

# GitHub Logs

## Permissions

This command can only modify: `.github/**/*.yaml`, `.github/**/*.md`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty or does not contain a run-id, respond
with: "Error: run-id required. Usage: /github:logs <run-id> [owner/repo]" and
STOP. Do not proceed with any tool calls.

---

Get logs for a GitHub Actions workflow run.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/logs-exec.sh $ARGUMENTS")
```
