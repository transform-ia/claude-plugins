---
description: "Run ESLint: /typescript:cmd-lint <directory>"
allowed-tools: [Bash]
---

# TypeScript Lint

## Permissions

**Permission Level**: 0 (Read-only analysis)

This command runs ESLint to check code quality without modifying files.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /typescript:cmd-lint DIRECTORY" and STOP. Do not proceed with
any tool calls.

---

Run the lint script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-lint.sh $ARGUMENTS")
```
