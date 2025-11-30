---
description: "Build Go project: /go:build <directory>"
allowed-tools: [Bash]
---

# Go Build

## Permissions

This command can only modify: `*.go`, `go.mod`, `go.sum`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:build <directory>" and STOP. Do not proceed with any tool
calls.

---

Run the build script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/build-exec.sh $ARGUMENTS")
```
