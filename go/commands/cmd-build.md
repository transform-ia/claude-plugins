---
description: "Build Go project: /go:cmd-build <directory>"
allowed-tools: [Bash]
---

# Go Build

## Permissions

This command is read-only for source files (generates binary artifact, does not modify `*.go`, `go.mod`, or `go.sum`).

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:cmd-build <directory>" and STOP. Do not proceed with any tool
calls.

---

Run the build script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/build-exec.sh $ARGUMENTS")
```
