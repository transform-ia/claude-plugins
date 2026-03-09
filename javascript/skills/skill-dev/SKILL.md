---
name: skill-dev
description: |
  JavaScript development tools and language server integration.

  Auto-activates when working with *.js, *.jsx, *.mjs, *.cjs, package.json files.

  DO NOT activate when:
  - Working with TypeScript files (use typescript plugin)
  - Working with Dockerfiles, Helm charts, or YAML files
  - User is doing Docker, Helm, or infrastructure work

  ## Slash Commands vs Skills

  **Slash Commands** (`/javascript:cmd-*`): Single-operation wrappers for specific tasks:
  - `/javascript:cmd-lint` - Run ESLint on JavaScript files
  - `/javascript:cmd-build` - Build JavaScript applications
  - `/javascript:cmd-test` - Run JavaScript tests

  **Skills** (`javascript:skill-dev`): Extended context for complex workflows involving:
  - Writing/editing JavaScript/React source code
  - Multi-file refactoring
  - Feature implementation
  - Component creation
  - Using MCP tools for semantic navigation (definition, references, etc.)

  Use slash commands for build/test/lint operations. The skill auto-activates when modifying JavaScript code.
allowed-tools: Read, Write(*.js, *.jsx, *.mjs, *.cjs, package.json), Edit(*.js, *.jsx, *.mjs, *.cjs, package.json), Glob, Grep, Bash(npm *), Bash(yarn *), Bash(node *), Bash(rm *.js), Bash(rm *.jsx), Bash(rm *.mjs), Bash(rm *.cjs), SlashCommand(/javascript:*), mcp__javascript-dev__*
---
