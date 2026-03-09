---
name: skill-ops
description: |
  Local Helm release management.

  ONLY activate when:
  - User explicitly requests /helm:skill-ops
  - User requests to install, upgrade, or uninstall a local Helm release
  - User asks about Helm release status, history, or troubleshooting

  DO NOT activate when:
  - Developing Helm charts (use helm:skill-dev)
  - Creating or editing workflow files (use github:skill-dev)
  - Working on Go, Docker, or other code
  - User mentions "helm" without release management context
allowed-tools: Read, Glob, Grep, Bash(helm *), Bash(kubectl get *)
---
