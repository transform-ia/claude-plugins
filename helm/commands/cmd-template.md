---
description:
  "Preview rendered templates: /helm:cmd-template [directory] [release-name]"
allowed-tools: [Bash]
---

# Helm Template

## Permissions

This command is READ-ONLY. It renders templates for preview without modifying
files.

---

Run helm template to preview rendered Kubernetes manifests.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-template.sh $ARGUMENTS")
```
