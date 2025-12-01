---
description: "Run Go tests: /go:cmd-test <directory> [package]"
allowed-tools: [Bash]
---

# Go Test

## Permissions

This command is read-only (runs tests, does not modify source files).

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:cmd-test <directory> [package]" and STOP. Do not proceed with
any tool calls.

---

Run the test script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/test-exec.sh $ARGUMENTS")
```
