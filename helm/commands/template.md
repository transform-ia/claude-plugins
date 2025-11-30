---
description:
  "Preview rendered templates: /helm:template [directory] [release-name]"
allowed-tools: [Bash]
---

# Helm Template

## Permissions

This command can only modify: `Chart.yaml`, `values.yaml`, `templates/**`,
`.helmignore`

---

Run helm template to preview rendered Kubernetes manifests.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/template-exec.sh $ARGUMENTS")
```
