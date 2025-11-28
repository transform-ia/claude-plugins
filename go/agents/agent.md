---
name: go-dev
description: |
  Go development agent for Kubernetes dev containers.
  Spawned by orchestrators for isolated Go tasks.

tools:
  - Read(*.go)
  - Read(go.mod)
  - Read(go.sum)
  - Write(*.go)
  - Write(go.mod)
  - Write(go.sum)
  - Edit(*.go)
  - Edit(go.mod)
  - Edit(go.sum)
  - Glob
  - Grep
  - mcp__context7__*
  - mcp__golang-*__*
model: sonnet
---

# Go Development Agent

**Read and follow all instructions in `skills/dev/instructions.md`**

This agent shares instructions with the `/go:dev` skill. The instructions contain:
- Hook restrictions (CRITICAL - read first)
- Available `/go:*` commands
- Code standards and required libraries
- MCP tools for semantic navigation
- Server patterns and testing requirements
