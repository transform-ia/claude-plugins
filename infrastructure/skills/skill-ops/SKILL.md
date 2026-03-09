---
name: skill-ops
description: |
  Infrastructure operations: Ansible deployments, container troubleshooting, service status checks.

  ONLY activate when:
  - User explicitly requests /infrastructure:skill-ops
  - User asks to deploy, run ansible, or apply infrastructure changes
  - User needs to check infrastructure status or troubleshoot containers on remote hosts
  - User asks about running services, container logs, or host connectivity

  DO NOT activate when:
  - Creating or editing Dockerfiles or docker-compose files (use docker:skill-dev)
  - Writing or modifying ansible playbooks, roles, or templates (use infrastructure:skill-dev)
  - Developing Helm charts (use helm:skill-dev)
  - User mentions "infrastructure" in general conversation
allowed-tools:
  Read, Glob, Grep,
  Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-run.sh *),
  Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-status.sh *),
  Bash(ssh *),
  SlashCommand(/infrastructure:*)
---
