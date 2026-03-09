---
name: skill-dev
description: |
  Dockerfile development, linting with hadolint, and image tag discovery.

  ONLY activate when user explicitly requests /docker:skill-dev OR is writing/editing Dockerfiles or docker-compose.yaml.

  DO NOT activate when:
  - Reading Dockerfiles without intent to edit
  - User mentions "docker" in a general context
  - Building or running containers (not editing Dockerfiles)
allowed-tools:
  Read, Write(Dockerfile*), Write(.dockerignore), Write(docker-compose.yaml),
  Write(.env.example), Edit(Dockerfile*), Edit(.dockerignore),
  Edit(docker-compose.yaml), Edit(.env.example), Glob, Grep,
  Bash(rm Dockerfile*), Bash(rm .dockerignore), SlashCommand(/docker:*),
  mcp__dockerhub__*
---
