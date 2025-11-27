---
name: go-dev
description: |
  Go development with Kubernetes dev containers.

  **Auto-activates when:**
  - User mentions: go, golang, go build, go test, go mod, golangci-lint
  - User refers to: *.go, go.mod, go.sum files
  - go.mod exists at the git repository root

instructions: guidelines.md
activation_rules:
  - when_authoring: "*.go"
  - when_authoring: "go.mod"
  - when_authoring: "go.sum"
---
