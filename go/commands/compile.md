---
description: "Build Go project: /go:compile <directory>"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/compile.sh *)]
---

# Go Build

## Permissions

**Permission Level**: 1 (Artifact Creation)

This command creates a binary artifact but does not modify source files.

**Created artifacts**:

- Compiled Go binary (in project directory)

**Source files unchanged**:

- `*.go` (not modified)
- `go.mod` (not modified)
- `go.sum` (not modified)

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:compile DIRECTORY" and STOP. Do not proceed with any
tool calls.

---

Run the build script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/compile.sh $ARGUMENTS")
```
