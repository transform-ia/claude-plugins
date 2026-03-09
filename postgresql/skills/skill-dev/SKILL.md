---
name: skill-dev
description: |
  PostgreSQL schema design, migrations, and query optimization.

  Auto-activates when working with *.sql or *.pgsql files.

  DO NOT activate when:
  - Working with MongoDB, Redis, or other non-SQL databases
  - Working with Dockerfile or YAML files
  - User is doing Docker or infrastructure work

allowed-tools:
  Read, Write(*.sql, *.pgsql), Edit(*.sql, *.pgsql), Glob, Grep,
  Bash(psql *), Bash(rm *.sql), SlashCommand(/postgresql:*)
---
