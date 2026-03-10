---
name: sqllint
description: Validate SQL syntax by checking with psql dry-run
usage: /postgresql:sqllint <file>
---

Validates SQL syntax using psql in a transaction that is always rolled back.

Command executed:
psql postgresql://dev:dev@localhost:5432/oauth2 -c "BEGIN;" -f <file> -c "ROLLBACK;"
