---
description: "Find unused values: /helm:cmd-check-unused-values [directory]"
allowed-tools: [Bash]
---

# Helm Check Unused Values

## Permissions

This command is READ-ONLY. It analyzes values.yaml usage without modifying
files. After analysis, the agent may offer to remove unused values using
Write/Edit tools.

---

Check for values in values\*.yaml that are not referenced in templates.

## Task

Run the analysis script:

```text
Bash("/workspace/sandbox/transform-ia/claude-plugins/helm/scripts/check-unused-values-exec.sh $ARGUMENTS")
```

If cleanup is needed, offer to remove the unused values from values.yaml.
