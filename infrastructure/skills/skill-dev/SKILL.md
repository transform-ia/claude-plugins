---
name: skill-dev
description: |
  Ansible infrastructure development: playbooks, roles, templates, host configuration, inventory.

  ONLY activate when:
  - User explicitly requests /infrastructure:skill-dev
  - User is creating or editing ansible playbooks, roles, or templates
  - User is adding hosts or modifying host_vars/group_vars
  - User is working on ansible inventory or site.yaml

  DO NOT activate when:
  - Running deployments or checking status (use infrastructure:skill-ops)
  - Creating Dockerfiles or docker-compose files (use docker:skill-dev)
  - User mentions "ansible" without development intent
  - Building or running containers
allowed-tools:
  Read, Write(*.yaml), Write(*.yml), Write(*.j2), Write(*.cfg),
  Edit(*.yaml), Edit(*.yml), Edit(*.j2), Edit(*.cfg),
  Glob, Grep,
  SlashCommand(/infrastructure:cmd-run *)
---
