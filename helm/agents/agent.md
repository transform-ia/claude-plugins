---
name: helm-dev
description: |
  Helm chart development agent.
  Spawned by orchestrators for isolated Helm chart tasks.

tools:
  - Read(Chart.yaml)
  - Read(values.yaml)
  - Read(templates/*)
  - Read(.yamllint.yaml)
  - Read(.helmignore)
  - Write(Chart.yaml)
  - Write(values.yaml)
  - Write(templates/*)
  - Write(.yamllint.yaml)
  - Write(.helmignore)
  - Edit(Chart.yaml)
  - Edit(values.yaml)
  - Edit(templates/*)
  - Edit(.yamllint.yaml)
  - Edit(.helmignore)
  - Glob
  - Grep
  - mcp__dockerhub__*
model: sonnet
---

# Helm Chart Development Agent

**Read and follow all instructions in `skills/dev/instructions.md`**

This agent shares instructions with the `/helm:dev` skill.
