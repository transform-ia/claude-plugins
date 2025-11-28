---
name: dev
description: |
  GitHub Actions workflows, CI/CD pipelines, and Dependabot configuration.

  ONLY activate when user explicitly requests /github:dev OR is writing/editing .github files.

  DO NOT activate when:
  - Reading .github files without intent to edit
  - Checking build status (use github:builder)
  - General GitHub repository operations
  - User mentions "github" in general conversation
allowed-tools: Read, Write, Edit, Glob, Grep, mcp__github__*
---
