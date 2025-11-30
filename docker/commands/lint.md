---
description: "Run hadolint: /docker:lint [Dockerfile]"
allowed-tools: [Bash]
---

# Docker Lint

## Permissions

This command can only modify: `Dockerfile`, `Dockerfile.*`, `.dockerignore`

---

Run hadolint using the plugin script.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```
