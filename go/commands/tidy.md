---
description: "Run go mod tidy: /go:tidy <directory>"
allowed-tools: [Bash]
---

# Go Tidy

## Permissions

This command can only modify: `*.go`, `go.mod`, `go.sum`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:tidy <directory>" and STOP. Do not proceed with any tool
calls.

---

Run the tidy script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/tidy-exec.sh $ARGUMENTS")
```
