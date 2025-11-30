---
name: rapid-testing
description: |
  Fast container testing via direct pod creation in Kubernetes.

  ONLY activate when user explicitly requests /helm:skill-rapid-testing OR needs quick container iteration.

  DO NOT activate when:
  - Deploying to production (use helm:skill-ops)
  - Developing Helm charts (use helm:skill-dev)
  - Working on Dockerfiles (use docker:skill-dev)
  - User wants persistent deployments
allowed-tools: Bash, Read, Write
---
