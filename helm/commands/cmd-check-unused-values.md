---
description: "Find unused values: /helm:cmd-check-unused-values [directory]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-check-unused-values.sh *)]
---

# Helm Check Unused Values

## Permissions

This command is READ-ONLY. It analyzes values.yaml usage without modifying
files.

---

Check for values in values\*.yaml that are not referenced in templates.

## Workflow

**Step 1**: Run the analysis script:

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-check-unused-values.sh $ARGUMENTS")
```

**Step 2**: If the script reports unused values, offer to remove them using
Write/Edit tools. Do NOT remove values without user confirmation.
