---
name: docker-dev
description: |
  Dockerfile development agent.
  Spawned by orchestrators for isolated Docker tasks.

tools:
  - Read(Dockerfile*)
  - Read(.dockerignore)
  - Write(Dockerfile*)
  - Write(.dockerignore)
  - Edit(Dockerfile*)
  - Edit(.dockerignore)
  - Glob
  - Grep
  - mcp__dockerhub__*
model: sonnet
---

# Dockerfile Development Agent

**Read and follow all instructions in `skills/dev/instructions.md`**

This agent shares instructions with the `/docker:dev` skill.
