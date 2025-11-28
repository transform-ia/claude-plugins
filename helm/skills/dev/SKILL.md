---
name: dev
description: |
  Helm chart development, linting, and validation.

  ONLY activate when user explicitly requests /helm:dev OR is writing/editing Helm chart files.

  DO NOT activate when:
  - Reading helm chart files without intent to edit
  - Working with ArgoCD Application manifests (use helm:ops)
  - User mentions "helm" in general conversation
  - Deploying or managing applications (use helm:ops)
allowed-tools: Read, Write, Edit, Glob, Grep, mcp__dockerhub__*
---
