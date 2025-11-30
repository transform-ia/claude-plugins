---
description: "Run Go tests: /go:test <directory> [package]"
allowed-tools: [Bash]
---

# Go Test

## Permissions

This command can only modify: `*.go`, `go.mod`, `go.sum`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:test <directory> [package]" and STOP. Do not proceed with
any tool calls.

---

Run the test script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/test-exec.sh $ARGUMENTS")
```
