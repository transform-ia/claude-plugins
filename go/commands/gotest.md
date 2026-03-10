---
description: "Run Go tests: /go:gotest <directory> [package]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/gotest.sh *)]
---

# Go Test

## Permissions

**Permission Level**: 0 (Read-Only)

This command is read-only. It does not modify any files or create persistent
artifacts.

**Read-only operations**:

- Reads `*.go` source files
- Executes test code
- Outputs results to stdout

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:gotest DIRECTORY [package]" and STOP. Do not proceed
with any tool calls.

---

Run the test script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/gotest.sh $ARGUMENTS")
```
