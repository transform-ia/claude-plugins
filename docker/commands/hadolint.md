---
description: "Run hadolint: /docker:hadolint [Dockerfile]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/hadolint.sh *)]
---

# Docker Lint

## Permissions

This command can only modify: `Dockerfile`, `Dockerfile.*`, `.dockerignore`

---

Run hadolint using the plugin script.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/hadolint.sh $ARGUMENTS")
```
