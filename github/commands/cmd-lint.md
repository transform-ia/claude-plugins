---
description: "Lint .github files: /github:cmd-lint [directory]"
allowed-tools: [Bash, Bash(git *), Bash(tree *)]
---

# GitHub Lint

## Permissions

This command can only modify: `.github/**/*.yaml`, `.github/**/*.md`

---

## Parameter Validation

**If $ARGUMENTS is empty, use current directory as default.**

If the specified directory does not exist, respond:
"Error: Directory not found. Usage: /github:cmd-lint [directory]"

DO NOT proceed with tool calls.

---

Run yamllint + prettier on .github directory.

## Workflow

**Step 1**: Run linters:
```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```

The script will exit with code 1 if linting fails.

**Step 2**: If linting fails, fix all issues before proceeding.

**Step 3**: Re-run lint until exit code 0 (success).
