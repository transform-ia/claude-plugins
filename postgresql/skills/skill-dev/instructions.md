# PostgreSQL Development

## Standards

### NEVER

- Use SERIAL or BIGSERIAL — use UUID or BIGINT GENERATED ALWAYS AS IDENTITY
- Use TIMESTAMP without timezone — always use TIMESTAMPTZ
- Omit indexes on foreign keys
- Store passwords in plaintext — use pgcrypto or application-level hashing
- Use SELECT \* in application code — always list columns explicitly

### ALWAYS

- Use UUID primary keys: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`
- Use snake_case for all table and column names
- Add `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` to every table
- Wrap schema changes in transactions
- Name constraints explicitly:
  `CONSTRAINT fk_table_col FOREIGN KEY (col) REFERENCES other_table(id)`
- Index foreign key columns
- Use JSONB (not JSON) for semi-structured data
- Add CHECK constraints for enum-like columns
- Use TEXT (not VARCHAR(n)) — PostgreSQL handles length efficiently

## Naming Conventions

| Element            | Pattern                          | Example                        |
| ------------------ | -------------------------------- | ------------------------------ |
| Tables             | plural snake_case                | users, organizations           |
| Columns            | singular snake_case              | user_id, created_at            |
| Indexes            | idx\_{table}\_{column(s)}        | idx_users_email                |
| FK constraints     | fk\_{table}\_{referenced_table}  | fk_tokens_users                |
| Unique constraints | uq\_{table}\_{column}            | uq_users_email                 |
| Check constraints  | ck\_{table}\_{column}            | ck_orders_status               |
| Primary keys       | pk\_{table}                      | pk_users                       |

## Migration Patterns

- **Additive-only**: add columns, tables, indexes — never DROP in production
  without a migration plan
- Use numbered prefix: `001_initial.sql`, `002_add_column.sql`
- Always test migrations:
  `psql -f migration.sql` inside a transaction
- Every migration file starts with `BEGIN;` and ends with `COMMIT;`
- Include a rollback comment block at the end of each migration

## Row-Level Security (RLS) with Hasura

- Hasura uses session variables (`x-hasura-user-id`, `x-hasura-org-id`) in
  permission rules
- RLS policies go in Hasura metadata (not PostgreSQL) when using Hasura
- But DO add PostgreSQL RLS for defense-in-depth on critical tables:

```sql
ALTER TABLE sensitive_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_isolation ON sensitive_data
  USING (user_id = current_setting('hasura.user')::UUID);
```

## Index Strategy

| Type    | Use Case                            | Example                                                        |
| ------- | ----------------------------------- | -------------------------------------------------------------- |
| B-tree  | Equality and range queries          | `CREATE INDEX idx_users_email ON users (email);`               |
| GIN     | JSONB and arrays (TEXT\[\])          | `CREATE INDEX idx_events_data ON events USING GIN (data);`     |
| Partial | Status/boolean columns              | `CREATE INDEX idx_orders_pending ON orders (status) WHERE status != 'completed';` |

- **Composite indexes**: put the most selective column first
- Always verify index usage with `EXPLAIN ANALYZE`

## Performance

- Use `EXPLAIN ANALYZE` to verify index usage before and after changes
- Avoid N+1 queries — use JOINs or Hasura relationships
- Run `VACUUM ANALYZE` after bulk operations
- Use connection pooling (PgBouncer) for high-concurrency workloads
- Prefer `EXISTS` over `IN` for correlated subqueries

## psql Tooling

| Command                    | Description              |
| -------------------------- | ------------------------ |
| `\d table_name`            | Describe table structure |
| `\di`                      | List all indexes         |
| `\l`                       | List databases           |
| `\dt`                      | List tables              |
| `\df`                      | List functions           |
| `EXPLAIN ANALYZE SELECT…`  | Show query plan          |

## Table Template

```sql
CREATE TABLE table_name (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  -- columns here
  created_at TIMESTAMPTZ NOT NULL    DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL    DEFAULT NOW()
);

CREATE INDEX idx_table_name_column ON table_name (column);
```

## Troubleshooting

### "psql: connection refused"

PostgreSQL is not running or the connection string is wrong. Verify with
`pg_isready -h localhost -p 5432`.

### "BLOCKED: Bash not allowed in PostgreSQL plugin context"

Use `/postgresql:cmd-*` slash commands instead of direct shell commands.

### Migration fails with "relation already exists"

The migration was partially applied. Check current schema with `\d` and write a
corrective migration.
