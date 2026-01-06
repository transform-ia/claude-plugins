---
description: "Get workflow logs: /github:cmd-logs <run-id> [owner/repo]"
allowed-tools: [Bash]
---

# GitHub Logs

## Permissions

This command is READ-ONLY. It retrieves GitHub Actions workflow logs using the
gh CLI. No file modifications are made.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty or does not contain a run-id, respond
with: "Error: run-id required. Usage: /github:cmd-logs `<run-id>` [owner/repo]"
and STOP. Do not proceed with any tool calls.

---

Get logs for a GitHub Actions workflow run.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-logs.sh $ARGUMENTS")
```
