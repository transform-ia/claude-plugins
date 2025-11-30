---
description: "Find unused values: /helm:check-unused-values [directory]"
allowed-tools: [Bash]
---

# Helm Check Unused Values

## Permissions

This command can only modify: `Chart.yaml`, `values.yaml`, `templates/**`,
`.helmignore`

---

Check for values in values\*.yaml that are not referenced in templates.

## Task

Run the analysis script:

```text
Bash("/workspace/sandbox/transform-ia/claude-plugins/helm/scripts/check-unused-values-exec.sh $ARGUMENTS")
```

If cleanup is needed, offer to remove the unused values from values.yaml.
