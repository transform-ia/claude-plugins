---
description:
  "Initialize Vite+React+TypeScript project: /typescript:vite-init <directory>"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/vite-init.sh *)]
---

# TypeScript Project Initialization

## Permissions

**Permission Level**: 2 (Project Creation)

This command creates new project files and directories.

**Created artifacts**:

- Vite project structure
- package.json with dependencies
- tsconfig.json
- vite.config.ts

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /typescript:vite-init DIRECTORY" and STOP. Do not proceed with
any tool calls.

---

Run the init script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/vite-init.sh $ARGUMENTS")
```
