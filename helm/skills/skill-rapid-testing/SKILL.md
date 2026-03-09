---
name: skill-rapid-testing
description: |
  Fast container testing via local Docker containers.

  ONLY activate when:
  - User explicitly requests /helm:skill-rapid-testing
  - User requests to test a container image locally using Docker

  DO NOT activate when:
  - Deploying to production (use helm:skill-ops)
  - Developing Helm charts (use helm:skill-dev)
  - Working on Dockerfiles (use docker:skill-dev)
  - User requests persistent deployments
allowed-tools: Bash(docker run *), Bash(docker logs *), Bash(docker exec *), Bash(docker rm *), Read, Write(/tmp/*)
---
