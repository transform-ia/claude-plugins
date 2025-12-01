---
name: ops
description: |
  Kubernetes operations for ArgoCD Application management.

  ONLY activate when:
  - User explicitly requests /helm:skill-ops
  - User requests to create, edit, or deploy ArgoCD Application manifests in /workspace/applications/
  - User asks about ArgoCD sync status, health, or deployment troubleshooting

  DO NOT activate when:
  - Developing Helm charts (use helm:skill-dev)
  - Creating or editing workflow files (use github:skill-dev)
  - Working on Go, Docker, or other code
  - User mentions "helm" without ArgoCD/deployment context
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---
