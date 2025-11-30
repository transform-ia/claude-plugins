---
name: builder
description: |
  GitHub Actions build monitoring and workflow status.

  ONLY activate when user asks about build status, workflow runs, or CI/CD failures.

  DO NOT activate when:
  - Creating or editing workflow files (use github:dev)
  - General GitHub operations
  - Repository management
allowed-tools: Read(.github/*), Glob, Grep, Bash(gh run list *), Bash(gh run view *), Bash(gh run watch *), Bash(gh workflow list *), Bash(gh workflow view *), Bash(gh api *), mcp__github__*
---
