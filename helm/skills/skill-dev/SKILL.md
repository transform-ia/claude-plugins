---
name: dev
description: |
  Helm chart development, linting, and validation.

  ONLY activate when user explicitly requests /helm:skill-dev OR is writing/editing Helm chart files.

  DO NOT activate when:
  - Reading helm chart files without intent to edit
  - Working with ArgoCD Application manifests (use helm:skill-ops)
  - User mentions "helm" in general conversation
  - Deploying or managing applications (use helm:skill-ops)
allowed-tools: Read, Write(Chart.yaml), Write(values.yaml), Write(templates/*), Write(.helmignore), Edit(Chart.yaml), Edit(values.yaml), Edit(templates/*), Edit(.helmignore), Glob, Grep, Bash(rm Chart.yaml), Bash(rm values.yaml), Bash(rm templates/*), Bash(rm .helmignore), SlashCommand(/helm:*), SlashCommand(/docker:cmd-image-tag *), mcp__dockerhub__*
---
