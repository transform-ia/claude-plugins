---
name: dev
description: |
  Dockerfile development, linting with hadolint, and image tag discovery.

  ONLY activate when user explicitly requests /docker:dev OR is writing/editing Dockerfiles.

  DO NOT activate when:
  - Reading Dockerfiles without intent to edit
  - Working with Docker Compose files (yaml)
  - User mentions "docker" in a general context
  - Building or running containers (not editing Dockerfiles)
allowed-tools: Read, Write, Edit, Glob, Grep, mcp__dockerhub__*
---
