---
description: "Run golangci-lint: /go:lint <directory>"
allowed-tools: [Bash]
---
Run the lint script using absolute path. Do NOT cd or change directory.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```
