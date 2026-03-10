---
description: "Initialize Go module: /go:mod-init <directory> <package-name>"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/mod-init.sh *)]
---

# Go Init

## Permissions

This command creates `go.mod` (initializes Go module).

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` does not contain both directory and package-name,
respond with: "Error: directory and package-name required. Usage: /go:mod-init
DIRECTORY PACKAGE-NAME" and STOP. Do not proceed with any tool calls.

---

Run the init script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/mod-init.sh $ARGUMENTS")
```
