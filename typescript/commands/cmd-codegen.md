---
description: "Run GraphQL Codegen: /typescript:cmd-codegen <directory>"
allowed-tools: [Bash]
---

# GraphQL Code Generation

## Permissions

**Permission Level**: 1 (Artifact Creation)

This command generates TypeScript types from GraphQL schema.

**Created artifacts**:

- `src/generated/graphql.ts` - Generated types and hooks

**Source files unchanged**:

- `*.graphql` files (read-only)
- `codegen.ts` (not modified)

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /typescript:cmd-codegen DIRECTORY" and STOP. Do not proceed
with any tool calls.

---

Run the codegen script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-codegen.sh $ARGUMENTS")
```

**Prerequisites**:

- GraphQL endpoint must be accessible
- `codegen.ts` must be configured
- GraphQL documents in `src/graphql/**/*.graphql`
