---
name: dev
description: |
  Markdown documentation linting and formatting.

  ONLY activate when user explicitly requests /markdown:dev OR is writing/editing .md files.

  DO NOT activate when:
  - Reading markdown files without intent to edit
  - Working on code that happens to have comments
  - User is doing non-documentation work
allowed-tools: Read, Write, Edit, Glob, Grep
---
