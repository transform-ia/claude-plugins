---
description: "Run markdownlint: /markdown:mdlint [path]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/mdlint.sh *)]
---

# Markdown Lint

## Permissions

This command can only access: `*.md`

Note: markdownlint can auto-fix issues (--fix flag is enabled).

---

Run markdownlint using the plugin script. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/mdlint.sh $ARGUMENTS")
```
