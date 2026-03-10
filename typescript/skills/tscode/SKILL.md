---
name: tscode
description: |
  TypeScript/React development with local toolchain.

  Auto-activates when working with *.ts, *.tsx, package.json, or tsconfig.json files.

  DO NOT activate when:
  - Working with Dockerfiles, Helm charts, or YAML files
  - The word "typescript" appears in a path or project name only
  - User is doing Docker, Helm, or infrastructure work

  ## Slash Commands vs Skills

  **Slash Commands** (`/typescript:*`): Single-operation wrappers for specific tasks:
  - `/typescript:vite-init` - Initialize Vite project
  - `/typescript:install` - Install npm dependencies
  - `/typescript:bundle` - Build project
  - `/typescript:dev` - Start dev server
  - `/typescript:eslint` - Run ESLint
  - `/typescript:gql-types` - Run GraphQL Codegen
  - `/typescript:typecheck` - Run TypeScript check

  **Skills** (`typescript:tscode`): Extended context for complex workflows involving:
  - Writing/editing TypeScript/React source code
  - Multi-file refactoring
  - Feature implementation
  - Component creation
  - Using MCP tools for semantic navigation (definition, references, etc.)

  Use slash commands for build/test/lint operations. The skill auto-activates when modifying TypeScript code.
allowed-tools:
  Read, Write(*.ts), Write(*.tsx), Write(*.json), Write(*.graphql),
  Write(*.css), Write(*.scss), Edit(*.ts), Edit(*.tsx), Edit(*.json),
  Edit(*.graphql), Edit(*.css), Edit(*.scss), Glob, Grep,
  Bash(rm *.ts), Bash(rm *.tsx), Bash(npm *), Bash(npx *),
  SlashCommand(/typescript:*), mcp__context7__*, mcp__typescript-*__*
---
