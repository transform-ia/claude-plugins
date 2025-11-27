---
description: "Build Go project: /go:build <directory>"
allowed-tools: [Bash]
---
Run the build script using absolute path. Do NOT cd or change directory.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/build-exec.sh $ARGUMENTS")
```
