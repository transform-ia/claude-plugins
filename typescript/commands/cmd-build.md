---
description: "Build TypeScript project: /typescript:cmd-build <directory>"
allowed-tools: [Bash]
---

# TypeScript Build

## Permissions

**Permission Level**: 1 (Artifact Creation)

This command creates build artifacts but does not modify source files.

**Created artifacts**:

- Compiled JavaScript in dist/
- Type declarations

**Source files unchanged**:

- `*.ts`, `*.tsx` (not modified)
- `package.json` (not modified)

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /typescript:cmd-build <directory>" and STOP. Do not proceed
with any tool calls.

---

Run the build script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-build.sh $ARGUMENTS")
```
