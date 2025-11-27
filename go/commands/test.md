---
description: "Run Go tests: /go:test <directory> [args]"
allowed-tools: [Bash]
---
Run the test script using absolute path. Do NOT cd or change directory.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/test-exec.sh $ARGUMENTS")
```
