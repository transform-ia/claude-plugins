---
name: dev
description: |
  Go development with Kubernetes dev containers.

  ONLY activate when user explicitly requests /go:dev OR is writing/editing .go, go.mod, go.sum files.

  DO NOT activate when:
  - Reading files in golang-chart, golang-image, or similar projects
  - Working with Dockerfiles, Helm charts, or YAML files
  - The word "golang" appears in a path or project name
  - User is doing Docker, Helm, or infrastructure work
allowed-tools: Read, Write, Edit, Glob, Grep
---
