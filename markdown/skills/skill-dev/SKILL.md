---
name: skill-dev
description: |
  Markdown documentation linting and formatting.

  ONLY activate when:
  - User explicitly requests /markdown:skill-dev, OR
  - User explicitly asks to create/edit/modify/update .md files

  DO NOT activate when:
  - User asks to READ .md files
  - User is working on code/configuration

allowed-tools:
  Read, Write(*.md), Edit(*.md), Glob, Grep, Bash(rm *.md),
  SlashCommand(/markdown:*)
---
