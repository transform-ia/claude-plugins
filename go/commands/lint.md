---
description: "Run golangci-lint: /go:lint <directory>"
allowed-tools: [Bash]
---

# Go Lint

## Permissions

This command can only modify: `*.go`, `go.mod`, `go.sum`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:lint <directory>" and STOP. Do not proceed with any tool
calls.

---

Run the lint script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```
