---
name: plugin-creator
description: |
  Creates new Claude Code plugins following established patterns.

  ONLY activate when user explicitly requests /orchestrator:plugin-creator OR wants to create a new plugin.

  DO NOT activate when:
  - Working within an existing plugin
  - Using other plugin commands
  - General development work
allowed-tools: Read, Write, Bash, Glob
---
