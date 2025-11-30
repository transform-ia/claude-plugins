---
name: rapid-testing
description: |
  Fast container testing via direct pod creation in Kubernetes.

  ONLY activate when:
  - User explicitly requests /helm:skill-rapid-testing
  - User requests to test a container image directly without deploying via ArgoCD

  DO NOT activate when:
  - Deploying to production (use helm:skill-ops)
  - Developing Helm charts (use helm:skill-dev)
  - Working on Dockerfiles (use docker:skill-dev)
  - User requests persistent deployments
allowed-tools: Bash, Read, Write
---
