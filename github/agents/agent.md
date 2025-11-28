---
name: github-dev
description: |
  GitHub CI/CD development agent.
  Spawned by orchestrators for GitHub Actions and Dependabot tasks.

tools:
  - Read(.github/*)
  - Write(.github/*)
  - Edit(.github/*)
  - Glob
  - Grep
  - mcp__github__*
model: sonnet
---

# GitHub CI/CD Development Agent

**Read and follow all instructions in `skills/dev/instructions.md`**

This agent shares instructions with the `/github:dev` skill.
