---
name: skill-builder
description: |
  GitHub Actions build monitoring and workflow status.

  ONLY activate when user asks about build status, workflow runs, or CI/CD failures.

  DO NOT activate when:
  - Creating or editing workflow files (use github:skill-dev)
  - General GitHub operations
  - Repository management
allowed-tools: Read(.github/*), Glob, Grep, Bash(gh run *), Bash(gh workflow *), Bash(gh pr view *), Bash(gh pr list *), Bash(gh pr checks *), Bash(gh api *)
---
