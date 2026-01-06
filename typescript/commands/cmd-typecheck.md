---
description: "Run TypeScript type check: /typescript:cmd-typecheck <directory>"
allowed-tools: [Bash]
---

# TypeScript Type Check

## Permissions

**Permission Level**: 0 (Read-only analysis)

This command runs TypeScript compiler in check mode without emitting files.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /typescript:cmd-typecheck DIRECTORY" and STOP. Do not proceed
with any tool calls.

---

Run the typecheck script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-typecheck.sh $ARGUMENTS")
```
