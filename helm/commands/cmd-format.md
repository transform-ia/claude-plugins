---
description: "Format helm chart yaml: /helm:cmd-format [directory]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-format.sh *)]
---

# Helm Format

## Permissions

This command modifies Chart.yaml and values.yaml only. Templates are not
modified (contain Go template syntax).

---

Run prettier on Chart.yaml and values.yaml.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-format.sh $ARGUMENTS")
```
