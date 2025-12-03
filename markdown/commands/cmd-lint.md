---
description: "Run markdownlint: /markdown:cmd-lint [path]"
allowed-tools: [Bash]
---

# Markdown Lint

## Permissions

This command can only access: `*.md`

Note: markdownlint can auto-fix issues (--fix flag is enabled).

---

Run markdownlint using the plugin script. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-lint.sh $ARGUMENTS")
```
