---
name: dev
description: |
  Repository detection and plugin orchestration.

  ONLY activate when user explicitly requests /orchestrator:dev or /orchestrator:detect.

  DO NOT activate when:
  - Working on specific file types (use appropriate plugin)
  - User is clearly working in one domain (go, docker, helm, etc.)
allowed-tools: Task, SlashCommand(/orchestrator:*)
---
