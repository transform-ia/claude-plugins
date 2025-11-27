---
description: "Initialize Go module: /go:init <directory> <package-name>"
allowed-tools: [Bash]
---
Run the init script using absolute path. Do NOT cd or change directory.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/init-exec.sh $ARGUMENTS")
```
