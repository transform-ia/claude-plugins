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
| i18n            | react-i18next + i18next     | ^15.x   |
| Testing         | Vitest                      | ^3.x    |
| Test Rendering  | @testing-library/react      | ^16.x   |

## Standards

### NEVER

- Use `any` type - always provide proper types
- Use `var` - use `const` or `let`
- Import from `node_modules` paths directly
- Put business logic in components - use hooks or services
- Use inline styles for repeated patterns - use theme or styled components
- Hardcode user-facing strings in JSX/TSX - all strings go through `t()`
  (react-i18next), even for single-language projects
- Ship code without tests - every component, hook, and utility MUST have tests

### ALWAYS

- Use TypeScript strict mode
- Define interfaces for all props
- Use functional components with hooks
- Co-locate related files (Component/Component.tsx, index.ts)
- Export from index.ts files for clean imports
- Use MUI theme for consistent styling
- Handle loading and error states in data fetching
- Wrap all user-facing strings with `t()` from react-i18next
- **Ship tests with every change** - target minimum 90% code coverage
- Co-locate test files next to source (Component.test.tsx next to
  Component.tsx)

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

## Internationalization (i18n)

**All user-facing strings MUST go through react-i18next**, even if the project
currently supports only one language. This is non-negotiable - retrofitting i18n
later is extremely costly.

```typescript
// WRONG - hardcoded string
<Typography>No items found</Typography>
<Button>Save</Button>

// CORRECT - translated string
import { useTranslation } from 'react-i18next';

const { t } = useTranslation();
<Typography>{t('items.empty')}</Typography>
<Button>{t('common.save')}</Button>
```

Translation files live in `src/locales/{lang}/translation.json`:

```json
{
  "common": {
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete"
  },
  "items": {
    "empty": "No items found"
  }
}
```

## Testing Requirements

**Every component, hook, and utility MUST have tests.** Code without tests is
incomplete. Target minimum **90% code coverage**.

- Use Vitest as the test runner (configured in `vite.config.ts`)
- Use `@testing-library/react` for component tests
- Test user interactions, not implementation details
- Co-locate test files: `Component.test.tsx` next to `Component.tsx`
- Run tests with `npx vitest` or `npx vitest run` (for CI)

```typescript
// src/components/MyComponent/MyComponent.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MyComponent } from './MyComponent';

describe('MyComponent', () => {
  it('renders title', () => {
    render(<MyComponent title="Hello" />);
    expect(screen.getByText('Hello')).toBeInTheDocument();
  });

  it('calls onAction when clicked', async () => {
    const onAction = vi.fn();
    render(<MyComponent title="Hello" onAction={onAction} />);
    await userEvent.click(screen.getByText('Hello'));
    expect(onAction).toHaveBeenCalledOnce();
  });
});
```

**What to test:**

- Components: rendering, user interactions, conditional display, error states
- Hooks: return values, state changes, side effects
- Utils: input/output, edge cases, error handling
- GraphQL: mock Apollo responses with `MockedProvider`

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

## OAuth2 PKCE Integration

- Generate verifier (96+ random bytes → base64url, 128 chars) + challenge (SHA-256 → base64url) client-side
- Store tokens in `sessionStorage` (not localStorage) — expires with tab
- After PKCE code exchange: call `POST /{org}/oauth2/hasura-token` with Bearer access_token for Hasura JWT
- Inject Hasura JWT via `Authorization: Bearer` in Apollo ApolloLink (`setContext` from `@apollo/client/link/context`)
- Vite proxy: `/v1/graphql` → Hasura, API routes → Go server, OAuth2 redirects are DIRECT (browser redirect to OAuth2 server, not proxied)
- Handle 401 from GraphQL: clear sessionStorage + redirect to authorize URL (use `onError` from `@apollo/client/link/error`)
- For file upload: use `fetch` with `FormData` (not Apollo) + `Authorization: Bearer <hasuraToken>` header
- For inline image display: fetch presigned URL from REST API → `<img src={url}>` or `<iframe>` for PDFs
- Callback path: `/callback` — detect `?code=...&state=...` in URL, exchange via PKCE, then redirect to `/`
- Dev port: 5176 (not 5174) to avoid conflicts with oauth2 web-test app
- VITE_OAUTH2_ORG_SLUG, VITE_OAUTH2_CLIENT_ID, VITE_OAUTH2_SERVER_URL, VITE_OAUTH2_REDIRECT_URI via import.meta.env
