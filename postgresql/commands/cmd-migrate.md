---
name: cmd-migrate
description: Run a PostgreSQL migration file against the development database
usage: /postgresql:cmd-migrate <file>
---

Runs the specified SQL migration file against the development PostgreSQL instance.

Connection: postgresql://dev:dev@localhost:5432/oauth2

Command executed:
psql postgresql://dev:dev@localhost:5432/oauth2 -f <file>
