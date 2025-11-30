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

## Workflow

**Step 1**: Run linters:

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/lint-exec.sh $ARGUMENTS")
```

The script will exit with code 1 if linting fails. Fix all issues before
proceeding.

**Step 2**: Run unused values check:

```text
/helm:cmd-check-unused-values $ARGUMENTS
```

This identifies orphaned values in values.yaml that are not referenced in
templates.
