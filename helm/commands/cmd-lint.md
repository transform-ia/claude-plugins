---
description: "Lint helm chart: /helm:cmd-lint [directory]"
allowed-tools: [Bash, Read, Grep, Glob]
---

# Helm Lint

## Permissions

This command modifies Chart.yaml and values.yaml (prettier formatting).
Templates are not modified.

---

Run helm lint + yamllint on the chart directory, then check for unused values.

## Step 1: Run linters

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```

## Step 2: Check for unused values

After linting passes, run `/helm:cmd-check-unused-values` on the same directory to
find orphaned values in values.yaml that are no longer referenced in templates.
