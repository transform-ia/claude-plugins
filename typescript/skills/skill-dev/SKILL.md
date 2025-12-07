---
name: skill-dev
description: |
  TypeScript/React development with Kubernetes dev containers.

  Auto-activates when working with *.ts, *.tsx, package.json, or tsconfig.json files.

  DO NOT activate when:
  - Working with Dockerfiles, Helm charts, or YAML files
  - The word "typescript" appears in a path or project name only
  - User is doing Docker, Helm, or infrastructure work

  ## Slash Commands vs Skills

  **Slash Commands** (`/typescript:cmd-*`): Single-operation wrappers for specific tasks:
  - `/typescript:cmd-init` - Initialize Vite project
  - `/typescript:cmd-build` - Build project
  - `/typescript:cmd-dev` - Start dev server
  - `/typescript:cmd-lint` - Run ESLint
  - `/typescript:cmd-codegen` - Run GraphQL Codegen
  - `/typescript:cmd-typecheck` - Run TypeScript check

  **Skills** (`typescript:skill-dev`): Extended context for complex workflows involving:
  - Writing/editing TypeScript/React source code
  - Multi-file refactoring
  - Feature implementation
  - Component creation
  - Using MCP tools for semantic navigation (definition, references, etc.)

  Use slash commands for build/test/lint operations. The skill auto-activates when modifying TypeScript code.
allowed-tools:
  Read, Write(*.ts), Write(*.tsx), Write(*.json), Write(*.graphql),
  Write(*.css), Edit(*.ts), Edit(*.tsx), Edit(*.json), Edit(*.graphql),
  Edit(*.css), Glob, Grep, Bash(rm *.ts), Bash(rm *.tsx),
  SlashCommand(/typescript:*), mcp__context7__*, mcp__typescript-*__*
---
