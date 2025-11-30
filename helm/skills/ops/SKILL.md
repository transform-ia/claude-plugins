---
name: ops
description: |
  Kubernetes operations for ArgoCD Application management.

  ONLY activate when user explicitly requests /helm:ops OR is managing ArgoCD Applications.

  DO NOT activate when:
  - Developing Helm charts (use helm:dev)
  - Creating or editing workflow files (use github:dev)
  - Working on Go, Docker, or other code
  - User mentions "helm" without ArgoCD/deployment context
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---
