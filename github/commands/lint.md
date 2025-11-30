---
description: "Lint .github files: /github:lint [directory]"
allowed-tools: [Bash]
---

# GitHub Lint

## Permissions

This command can only modify: `.github/**/*.yaml`, `.github/**/*.md`

---

Run yamllint + prettier on .github directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```
