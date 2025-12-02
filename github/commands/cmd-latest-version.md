---
description: "Get latest semantic version: /github:cmd-latest-version <path>"
allowed-tools: [Bash]
---

# GitHub Latest Version

## Permissions

This command is READ-ONLY. It queries git tags from the local repository.
No file modifications are made.

---

## Parameter Validation

**Required argument:**
- `<path>`: Path to a git repository (required)

The path argument is mandatory and must be a valid git repository.

If validation fails, respond with:
"Error: Not a git repository: [path]"

DO NOT proceed with tool calls if path is invalid.

---

Query latest semantic version tag from git repository.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/latest-version-exec.sh $ARGUMENTS")
```
