---
name: rapid-testing
description: |
  Fast container testing via direct pod creation in Kubernetes.

  ONLY activate when user explicitly requests /helm:rapid-testing OR needs quick container iteration.

  DO NOT activate when:
  - Deploying to production (use helm:ops)
  - Developing Helm charts (use helm:dev)
  - Working on Dockerfiles (use docker:dev)
  - User wants persistent deployments
allowed-tools: Bash, Read, Write
---
