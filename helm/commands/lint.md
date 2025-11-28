---
description: "Lint helm chart: /helm:lint [directory]"
allowed-tools: [Bash]
---
Run helm lint + yamllint on the chart directory.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```
