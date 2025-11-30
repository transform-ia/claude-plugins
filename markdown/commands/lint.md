---
description: "Run markdownlint: /markdown:lint [path]"
allowed-tools: [Bash]
---

# Markdown Lint

## Permissions

This command can only modify: `*.md`

---

Run markdownlint using the plugin script. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```
