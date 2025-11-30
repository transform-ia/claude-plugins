---
description: "Run Go project: /go:run <directory> [args]"
allowed-tools: [Bash]
---

# Go Run

## Permissions

This command can only modify: `*.go`, `go.mod`, `go.sum`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:run <directory> [args]" and STOP. Do not proceed with any
tool calls.

---

Run the run script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/run-exec.sh $ARGUMENTS")
```
