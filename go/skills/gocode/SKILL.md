---
name: gocode
description: |
  Go development with local toolchain.

  Auto-activates when working with *.go, go.mod, or go.sum files.

  DO NOT activate when:
  - Working with Dockerfiles, Helm charts, or YAML files
  - The word "golang" appears in a path or project name
  - User is doing Docker, Helm, or infrastructure work

  ## Slash Commands vs Skills

  **Slash Commands** (`/go:*`): Single-operation wrappers for specific tasks:
  - `/go:mod-init` - Initialize go.mod
  - `/go:tidy` - Update dependencies
  - `/go:compile` - Build binary
  - `/go:gotest` - Run tests
  - `/go:golint` - Run linter
  - `/go:run` - Execute binary

  **Skills** (`go:gocode`): Extended context for complex workflows involving:
  - Writing/editing Go source code
  - Multi-file refactoring
  - Feature implementation
  - Bug fixes requiring code changes
  - Using MCP tools for semantic navigation (definition, references, callers, etc.)

  Use slash commands for build/test/lint operations. The skill auto-activates when modifying Go code.
allowed-tools:
  Read, Write(*.go), Write(go.mod), Write(go.sum), Edit(*.go), Edit(go.mod),
  Edit(go.sum), Glob, Grep, Bash(rm *.go), Bash(rm go.mod), Bash(rm go.sum),
  SlashCommand(/go:*), mcp__context7__*, mcp__golang-*__*
---
