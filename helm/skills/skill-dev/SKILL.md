---
name: skill-dev
description: |
  Helm chart development, linting, and validation.

  ONLY activate when:
  - User explicitly requests /helm:skill-dev
  - User requests to create, modify, or lint Chart.yaml, values.yaml, or templates/*

  DO NOT activate when:
  - Reading helm chart files without modification
  - Working with ArgoCD Application manifests (use helm:skill-ops)
  - User mentions "helm" in general conversation
  - Deploying or managing applications (use helm:skill-ops)
allowed-tools:
  Read, Write(Chart.yaml), Write(values.yaml), Write(templates/*),
  Write(.helmignore), Edit(Chart.yaml), Edit(values.yaml), Edit(templates/*),
  Edit(.helmignore), Glob, Grep, Bash(rm Chart.yaml), Bash(rm values.yaml),
  Bash(rm templates/*), Bash(rm .helmignore), SlashCommand(/helm:*),
  SlashCommand(/docker:cmd-image-tag *), mcp__dockerhub__*
---
