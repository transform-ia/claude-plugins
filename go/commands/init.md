---
description: "Initialize Go module: /go:init <directory> <package-name>"
allowed-tools: [Bash]
---

# Go Init

## Permissions

This command can only modify: `*.go`, `go.mod`, `go.sum`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` does not contain both directory and package-name,
respond with: "Error: directory and package-name required. Usage: /go:init
<directory> <package-name>" and STOP. Do not proceed with any tool calls.

---

Run the init script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/init-exec.sh $ARGUMENTS")
```
