---
description: "Run go mod tidy: /go:tidy <directory>"
allowed-tools: [Bash]
---
Run the tidy script using absolute path. Do NOT cd or change directory.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/tidy-exec.sh $ARGUMENTS")
```
