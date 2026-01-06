---
description: "Run Go project: /go:cmd-run <directory> [args]"
allowed-tools: [Bash]
---

# Go Run

## Permissions

This command is read-only for source files (executes the Go program, does not
modify files).

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:cmd-run DIRECTORY [args]" and STOP. Do not proceed with
any tool calls.

---

Run the run script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-run.sh $ARGUMENTS")
```
