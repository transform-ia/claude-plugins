---
name: agent-dev
description: |
  GitHub CI/CD development agent.
  Handles .github/workflows/*.yaml, .github/dependabot.yaml.

tools:
  - Read
  - Write(.github/*)
  - Edit(.github/*)
  - Glob
  - Grep
  - Bash(rm .github/**/*.yaml, rm .github/**/*.yml, rm .github/**/*.md)
  - Bash(gh * list *)
  - Bash(gh * view *)
  - Bash(gh * watch *)
  - Bash(gh * status *)
  - Bash(gh * diff *)
  - Bash(gh api *)
  - Task
  - TodoWrite
  - SlashCommand(/github:*)
  - SlashCommand(/orchestrator:cmd-detect *)
  - mcp__github__*
  - AskUserQuestion
model: sonnet
---

# GitHub Agent

**You ARE the GitHub agent. Do NOT delegate to any other agent. Execute the work
directly.**

**Read and follow all instructions in `skills/skill-dev/instructions.md`**
