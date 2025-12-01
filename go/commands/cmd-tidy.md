---
description: "Run go mod tidy: /go:cmd-tidy <directory>"
allowed-tools: [Bash]
---

# Go Tidy

## Permissions

This command modifies `go.mod` and `go.sum` (updates dependencies).

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:cmd-tidy <directory>" and STOP. Do not proceed with any tool
calls.

---

Run the tidy script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/tidy-exec.sh $ARGUMENTS")
```
