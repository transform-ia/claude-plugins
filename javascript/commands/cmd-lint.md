---
description: "Run ESLint: /javascript:cmd-lint [file] [options]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-lint.sh *)]
---

# JavaScript Lint

## Permissions

This command can only modify: `*.js`, `*.jsx`, `*.mjs`, `*.cjs`

---

Run ESLint using the plugin script.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-lint.sh $ARGUMENTS")
```
