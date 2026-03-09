---
description: "Lint helm chart: /helm:cmd-lint [directory]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-lint.sh *), Read, Grep, Glob]
---

# Helm Lint

## Permissions

**Permission Level**: 2 (Auto-Formatting)

This command auto-formats Chart.yaml and values.yaml using prettier. Templates
are validated but not modified.

**Modified files**:

- `Chart.yaml` (formatted)
- `values.yaml` (formatted)

**Read-only checks**:

- `templates/*` (validated, not modified)

---

Run helm lint + yamllint on the chart directory, then check for unused values.

## Workflow

**Step 1**: Run linters:

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-lint.sh $ARGUMENTS")
```

The script will exit with code 1 if linting fails. Fix all issues before
proceeding.

**Step 2**: Run unused values check:

```text
/helm:cmd-check-unused-values $ARGUMENTS
```

This identifies orphaned values in values.yaml that are not referenced in
templates.
