---
name: deploy
description: |
  Infrastructure operations: Ansible deployments, container troubleshooting, service status checks.

  ONLY activate when:
  - User explicitly requests /infrastructure:deploy
  - User asks to deploy, run ansible, or apply infrastructure changes
  - User needs to check infrastructure status or troubleshoot containers on remote hosts
  - User asks about running services, container logs, or host connectivity

  DO NOT activate when:
  - Creating or editing Dockerfiles or docker-compose files (use docker:container)
  - Writing or modifying ansible playbooks, roles, or templates (use infrastructure:ansible)
  - Developing Helm charts (use helm:agent-dev)
  - User mentions "infrastructure" in general conversation
allowed-tools:
  Read, Glob, Grep,
  Bash(${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh *),
  Bash(${CLAUDE_PLUGIN_ROOT}/scripts/host-status.sh *),
  Bash(ssh *),
  SlashCommand(/infrastructure:*)
---
