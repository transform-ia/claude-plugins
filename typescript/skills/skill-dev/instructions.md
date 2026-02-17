# TypeScript/React Development

## Prerequisites

Before starting ANY task, verify current branch is `master` and up-to-date with
remote. If not, STOP and report to user.

## Technology Stack

| Purpose         | Library                     | Version |
| --------------- | --------------------------- | ------- |
| Build Tool      | Vite                        | ^7.x    |
| Framework       | React                       | ^19.x   |
| Type System     | TypeScript                  | ^5.x    |
| UI Components   | Material-UI (@mui/material) | ^7.x    |
| Data Grid       | @mui/x-data-grid            | ^8.x    |
| Date Pickers    | @mui/x-date-pickers         | ^8.x    |
| GraphQL Client  | Apollo Client               | ^4.x    |
| Code Generation | GraphQL Codegen             | ^6.x    |
| Form Handling   | react-hook-form             | ^7.x    |
| Validation      | Zod                         | ^4.x    |
| Form Resolver   | @hookform/resolvers         | ^5.x    |
| Routing         | react-router-dom            | ^7.x    |
| Date Utilities  | date-fns                    | ^4.x    |

## Standards

### NEVER

- Use `any` type - always provide proper types
- Use `var` - use `const` or `let`
- Import from `node_modules` paths directly
- Put business logic in components - use hooks or services
- Use inline styles for repeated patterns - use theme or styled components

### ALWAYS

- Use TypeScript strict mode
- Define interfaces for all props
- Use functional components with hooks
- Co-locate related files (Component/Component.tsx, index.ts)
- Export from index.ts files for clean imports
- Use MUI theme for consistent styling
- Handle loading and error states in data fetching

## Project Structure

```text
src/
├── config/           # Configuration (Apollo, theme, etc.)
├── generated/        # Auto-generated files (GraphQL types)
├── graphql/          # GraphQL operations
│   ├── fragments/    # Reusable fragments
│   ├── queries/      # Query documents
│   └── mutations/    # Mutation documents
├── components/       # Reusable UI components
│   ├── Layout/       # App layout with navigation
│   └── index.ts      # Barrel export
├── pages/            # Route pages
│   └── index.ts      # Barrel export
├── hooks/            # Custom React hooks
├── utils/            # Utility functions
├── App.tsx           # Root component with providers
└── main.tsx          # Entry point
```

## Component Patterns

Reference files in `assets/` for complete examples:

| Pattern          | Reference File                           |
| ---------------- | ---------------------------------------- |
| List page        | `assets/examples/ListPage.tsx`           |
| Form page        | `assets/examples/FormPage.tsx`           |
| Layout           | `assets/examples/Layout.tsx`             |
| Loading spinner  | `assets/examples/LoadingSpinner.tsx`     |
| Error alert      | `assets/examples/ErrorAlert.tsx`         |
| Confirm dialog   | `assets/examples/ConfirmDialog.tsx`      |
| Page header      | `assets/examples/PageHeader.tsx`         |
| Apollo config    | `assets/templates/apollo.ts.tmpl`        |
| MUI theme        | `assets/templates/theme.ts.tmpl`         |
| App root         | `assets/templates/App.tsx.tmpl`          |
| Codegen config   | `assets/templates/codegen.ts.tmpl`       |

### Component File Structure (Quick Reference)

```typescript
// src/components/MyComponent/MyComponent.tsx
import { Box, Typography } from '@mui/material';

interface MyComponentProps {
  title: string;
  onAction?: () => void;
}

export function MyComponent({ title, onAction }: MyComponentProps) {
  return (
    <Box onClick={onAction}>
      <Typography variant="h6">{title}</Typography>
    </Box>
  );
}
```

```typescript
// src/components/MyComponent/index.ts
export { MyComponent } from "./MyComponent";
```

### Required Base Components

Always create these for consistency: LoadingSpinner, ErrorAlert, EmptyState,
PageHeader, ConfirmDialog.

## GraphQL Operations

### Fragment Pattern

```graphql
fragment ItemFields on items {
  id
  name
  description
  status
  created_at
  updated_at
}
```

### Query Pattern

```graphql
query GetItems($where: items_bool_exp, $orderBy: [items_order_by!], $limit: Int) {
  items(where: $where, order_by: $orderBy, limit: $limit) {
    ...ItemFields
  }
  items_aggregate(where: $where) {
    aggregate { count }
  }
}
```

### Mutation Pattern

```graphql
mutation CreateItem($input: items_insert_input!) {
  insert_items_one(object: $input) {
    ...ItemFields
  }
}
```

## MCP Tools (TypeScript Language Server)

Prefer MCP tools over grep - they understand TypeScript semantics:

```text
mcp__typescript-*__definition   - Go to definition
mcp__typescript-*__references   - Find all references
mcp__typescript-*__hover        - Type information
mcp__typescript-*__diagnostics  - TypeScript errors
```

## Environment Variables

All client-side env vars must be prefixed with `VITE_`:

```bash
VITE_GRAPHQL_ENDPOINT=http://your-graphql-endpoint/v1/graphql
VITE_HASURA_ADMIN_SECRET=your-secret
```

## Troubleshooting

### "Node.js or npm not found"

Install Node.js (includes npm) and ensure both are on PATH.

### Type errors from GraphQL Codegen

Run `/typescript:cmd-codegen <dir>` to regenerate types.

### "Module not found" errors

Check package.json dependencies, run `npm install`, verify import paths.
