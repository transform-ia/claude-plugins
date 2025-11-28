---
description: "Lint helm chart: /helm:lint [directory]"
allowed-tools: [Bash, Read, Grep, Glob]
---
Run helm lint + yamllint on the chart directory, then check for unused values.

## Step 1: Run linters

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```

## Step 2: Check for unused values

After linting passes, run `/helm:check-unused-values` on the same directory to find orphaned values in values.yaml that are no longer referenced in templates.
