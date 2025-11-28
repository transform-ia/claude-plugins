---
description: "Lint .github files: /github:lint [directory]"
allowed-tools: [Bash]
---
Run yamllint + prettier on .github directory.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```
