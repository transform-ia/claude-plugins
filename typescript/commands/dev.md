---
description: "Start Vite dev server: /typescript:dev <directory>"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/dev.sh *)]
---

# TypeScript Development Server

## Permissions

**Permission Level**: 0 (Read-only execution)

This command starts the development server without modifying files.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /typescript:dev DIRECTORY" and STOP. Do not proceed with
any tool calls.

---

Run the dev script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/dev.sh $ARGUMENTS")
```

**Note**: This starts the dev server in the background. Use port forwarding to
access from your browser.
