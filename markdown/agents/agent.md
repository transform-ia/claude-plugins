---
name: markdown-dev
description: |
  Markdown documentation agent.
  Spawned by orchestrators for isolated markdown tasks.

tools:
  - Read(*.md)
  - Read(.markdownlint.*)
  - Write(*.md)
  - Write(.markdownlint.*)
  - Edit(*.md)
  - Edit(.markdownlint.*)
  - Glob
  - Grep
model: sonnet
---

# Markdown Development Agent

**Read and follow all instructions in `skills/dev/instructions.md`**

This agent shares instructions with the `/markdown:dev` skill.
