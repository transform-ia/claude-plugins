---
name: skill-dev
description: |
  GitHub Actions workflows, CI/CD pipelines, and Dependabot configuration.

  ONLY activate when:
  - User explicitly requests /github:skill-dev
  - User requests to create, modify, or lint files in .github/ directory

  DO NOT activate when:
  - Reading .github/ files without modification intent
  - Checking build status (use github:skill-builder skill)
  - General GitHub repository operations
  - User mentions "github" in general conversation
allowed-tools: Read, Write(.github/*), Edit(.github/*), Glob, Grep, Bash(rm .github/**/*.yaml, rm .github/**/*.yml, rm .github/**/*.md), Bash(gh * list *), Bash(gh * view *), Bash(gh * watch *), Bash(gh * status *), Bash(gh * diff *), Bash(gh api *), Task, TodoWrite, SlashCommand(/github:*), SlashCommand(/orchestrator:cmd-detect *), mcp__github__*, AskUserQuestion
---
