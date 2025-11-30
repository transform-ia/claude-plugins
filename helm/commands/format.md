---
description: "Format helm chart yaml: /helm:format [directory]"
allowed-tools: [Bash]
---

# Helm Format

## Permissions

This command can only modify: `Chart.yaml`, `values.yaml`, `templates/**`,
`.helmignore`

---

Run prettier on Chart.yaml and values.yaml.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/format-exec.sh $ARGUMENTS")
```
