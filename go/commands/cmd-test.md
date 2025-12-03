---
description: "Run Go tests: /go:cmd-test <directory> [package]"
allowed-tools: [Bash]
---

# Go Test

## Permissions

**Permission Level**: 0 (Read-Only)

This command is read-only. It does not modify any files or create persistent artifacts.

**Read-only operations**:
- Reads `*.go` source files
- Executes test code
- Outputs results to stdout

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:cmd-test <directory> [package]" and STOP. Do not proceed with
any tool calls.

---

Run the test script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-test.sh $ARGUMENTS")
```
