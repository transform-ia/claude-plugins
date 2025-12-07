# TypeScript/React Development

## Prerequisites

**CRITICAL: Branch Verification**

Before starting ANY task:

1. **Verify current branch is `master`**
2. **Verify branch is up-to-date with remote** (`git pull`)
3. **If NOT on master or not up-to-date:**
   - STOP immediately
   - Report to user: "Task cannot proceed - not on latest master branch"
   - Use AskUserQuestion to confirm with user

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

```
src/
├── config/           # Configuration (Apollo, theme, etc.)
├── generated/        # Auto-generated files (GraphQL types)
├── graphql/          # GraphQL operations
│   ├── fragments/    # Reusable fragments
│   ├── queries/      # Query documents
│   └── mutations/    # Mutation documents
├── components/       # Reusable UI components
│   ├── Layout/       # App layout with navigation
│   ├── TaskCard/     # Example domain component
│   └── index.ts      # Barrel export
├── pages/            # Route pages
│   ├── Dashboard/
│   ├── Tasks/        # List, Detail, Form
│   └── index.ts      # Barrel export
├── hooks/            # Custom React hooks
├── utils/            # Utility functions
├── App.tsx           # Root component with providers
└── main.tsx          # Entry point
```

## Component Patterns

### Component File Structure

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

### Page Component Pattern

```typescript
// src/pages/Items/ItemList.tsx
import { useState } from 'react';
import { useQuery, useMutation, gql } from '@apollo/client';
import { Box, Grid, Snackbar, Alert } from '@mui/material';
import { PageHeader, LoadingSpinner, ErrorAlert, EmptyState, ConfirmDialog } from '../../components';

const GET_ITEMS = gql`
  query GetItems($where: items_bool_exp) {
    items(where: $where, order_by: { created_at: desc }) {
      id
      name
      status
    }
    items_aggregate(where: $where) {
      aggregate { count }
    }
  }
`;

const DELETE_ITEM = gql`
  mutation DeleteItem($id: uuid!) {
    delete_items_by_pk(id: $id) { id }
  }
`;

export function ItemList() {
  const navigate = useNavigate();
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [snackbar, setSnackbar] = useState<{
    open: boolean;
    message: string;
    severity: 'success' | 'error';
  }>({ open: false, message: '', severity: 'success' });

  const { data, loading, error, refetch } = useQuery(GET_ITEMS);

  const [deleteItem] = useMutation(DELETE_ITEM, {
    onCompleted: () => {
      setSnackbar({ open: true, message: 'Item deleted', severity: 'success' });
      refetch();
    },
    onError: (err) => {
      setSnackbar({ open: true, message: err.message, severity: 'error' });
    },
  });

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorAlert message={error.message} onRetry={refetch} />;

  const items = data?.items || [];

  return (
    <Box>
      <PageHeader
        title="Items"
        actionLabel="New Item"
        onAction={() => navigate('/items/new')}
      />
      {/* ... rest of component */}
    </Box>
  );
}
```

### Form Component Pattern

```typescript
// src/pages/Items/ItemForm.tsx
import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, gql } from '@apollo/client';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Box, Card, CardContent, TextField, Button } from '@mui/material';

const itemSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  description: z.string().optional(),
  status: z.enum(['active', 'inactive']),
});

type ItemFormData = z.infer<typeof itemSchema>;

export function ItemForm() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const isEdit = !!id;

  const { control, handleSubmit, reset, formState: { errors } } = useForm<ItemFormData>({
    resolver: zodResolver(itemSchema),
    defaultValues: { name: '', description: '', status: 'active' },
  });

  // ... query and mutation setup

  const onSubmit = (data: ItemFormData) => {
    if (isEdit) {
      updateItem({ variables: { id, input: data } });
    } else {
      createItem({ variables: { input: data } });
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Card>
        <CardContent>
          <Controller
            name="name"
            control={control}
            render={({ field }) => (
              <TextField
                {...field}
                label="Name"
                fullWidth
                required
                error={!!errors.name}
                helperText={errors.name?.message}
              />
            )}
          />
        </CardContent>
      </Card>
    </form>
  );
}
```

## Apollo Client Setup

```typescript
// src/config/apollo.ts
import { ApolloClient, InMemoryCache, HttpLink } from "@apollo/client";

const httpLink = new HttpLink({
  uri: import.meta.env.VITE_GRAPHQL_ENDPOINT,
  headers: {
    "x-hasura-admin-secret": import.meta.env.VITE_HASURA_ADMIN_SECRET || "",
  },
});

export const apolloClient = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: "cache-and-network",
    },
  },
});
```

## MUI Theme Setup

```typescript
// src/config/theme.ts
import { createTheme } from "@mui/material/styles";

export const theme = createTheme({
  palette: {
    primary: {
      main: "#4CAF50",
      light: "#81C784",
      dark: "#388E3C",
    },
    secondary: {
      main: "#FF9800",
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h4: { fontWeight: 600 },
    h5: { fontWeight: 600 },
    h6: { fontWeight: 600 },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          textTransform: "none",
          fontWeight: 600,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: "0 2px 8px rgba(0,0,0,0.08)",
        },
      },
    },
  },
});
```

## GraphQL Codegen Setup

```typescript
// codegen.ts
import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  schema: {
    "http://your-graphql-endpoint/v1/graphql": {
      headers: {
        "x-hasura-admin-secret": process.env.HASURA_ADMIN_SECRET || "",
      },
    },
  },
  documents: ["src/graphql/**/*.graphql"],
  generates: {
    "./src/generated/graphql.ts": {
      plugins: [
        "typescript",
        "typescript-operations",
        "typescript-react-apollo",
      ],
      config: {
        withHooks: true,
        withHOC: false,
        withComponent: false,
        scalars: {
          uuid: "string",
          timestamptz: "string",
          numeric: "number",
          date: "string",
        },
        enumsAsTypes: true,
        skipTypename: false,
        dedupeFragments: true,
      },
    },
  },
};

export default config;
```

## GraphQL Operations

### Fragment Pattern

```graphql
# src/graphql/fragments/item.graphql
fragment ItemFields on items {
  id
  name
  description
  status
  created_at
  updated_at
}

fragment ItemWithRelations on items {
  ...ItemFields
  category {
    id
    name
  }
  owner {
    id
    name
  }
}
```

### Query Pattern

```graphql
# src/graphql/queries/items.graphql
query GetItems(
  $where: items_bool_exp
  $orderBy: [items_order_by!]
  $limit: Int
) {
  items(where: $where, order_by: $orderBy, limit: $limit) {
    ...ItemFields
  }
  items_aggregate(where: $where) {
    aggregate {
      count
    }
  }
}

query GetItem($id: uuid!) {
  items_by_pk(id: $id) {
    ...ItemWithRelations
  }
}
```

### Mutation Pattern

```graphql
# src/graphql/mutations/items.graphql
mutation CreateItem($input: items_insert_input!) {
  insert_items_one(object: $input) {
    ...ItemFields
  }
}

mutation UpdateItem($id: uuid!, $input: items_set_input!) {
  update_items_by_pk(pk_columns: { id: $id }, _set: $input) {
    ...ItemFields
  }
}

mutation DeleteItem($id: uuid!) {
  delete_items_by_pk(id: $id) {
    id
  }
}
```

## Routing Setup

```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { ApolloProvider } from '@apollo/client';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';

import { apolloClient } from './config/apollo';
import { theme } from './config/theme';
import { Layout } from './components';
import { Dashboard, ItemList, ItemDetail, ItemForm } from './pages';

function App() {
  return (
    <ApolloProvider client={apolloClient}>
      <ThemeProvider theme={theme}>
        <LocalizationProvider dateAdapter={AdapterDateFns}>
          <CssBaseline />
          <BrowserRouter>
            <Routes>
              <Route path="/" element={<Layout />}>
                <Route index element={<Dashboard />} />
                <Route path="items" element={<ItemList />} />
                <Route path="items/new" element={<ItemForm />} />
                <Route path="items/:id" element={<ItemDetail />} />
                <Route path="items/:id/edit" element={<ItemForm />} />
              </Route>
            </Routes>
          </BrowserRouter>
        </LocalizationProvider>
      </ThemeProvider>
    </ApolloProvider>
  );
}

export default App;
```

## Common Components

### Layout Component

```typescript
// src/components/Layout/Layout.tsx
import { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import {
  AppBar, Box, Drawer, IconButton, List, ListItem, ListItemButton,
  ListItemIcon, ListItemText, Toolbar, Typography,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';

const DRAWER_WIDTH = 240;

export function Layout() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  // ... drawer content and navigation logic

  return (
    <Box sx={{ display: 'flex' }}>
      {/* AppBar, Drawer, Main content with Outlet */}
    </Box>
  );
}
```

### Reusable UI Components

Always create these base components for consistency:

- `LoadingSpinner` - Loading state indicator
- `ErrorAlert` - Error display with retry option
- `EmptyState` - Empty list state with action button
- `PageHeader` - Page title, subtitle, breadcrumbs, actions
- `ConfirmDialog` - Confirmation modal for destructive actions

## MCP Tools (TypeScript Language Server)

Prefer MCP tools over grep - they understand TypeScript semantics:

```text
mcp__typescript-*__definition   - Go to definition
mcp__typescript-*__references   - Find all references
mcp__typescript-*__callers      - Who calls this function
mcp__typescript-*__callees      - What does this function call
mcp__typescript-*__hover        - Type information
mcp__typescript-*__diagnostics  - TypeScript errors
```

## Environment Variables

```bash
# .env
VITE_GRAPHQL_ENDPOINT=http://your-graphql-endpoint/v1/graphql
VITE_HASURA_ADMIN_SECRET=your-secret
```

All environment variables used in client code must be prefixed with `VITE_`.

## Troubleshooting

### "No TypeScript development pod found"

**Cause**: typescript-chart deployment not created or workdir label missing.

**Fix**:

1. Check ArgoCD application exists
2. Verify deployment with proper labels
3. Update to typescript-chart with `workdir:` value

### Type errors from GraphQL Codegen

**Cause**: Generated types out of sync with schema.

**Fix**: Run `/typescript:cmd-codegen <dir>` to regenerate types.

### "Module not found" errors

**Cause**: Missing dependencies or incorrect imports.

**Fix**:

1. Check package.json has all required dependencies
2. Run `npm install` in the project directory
3. Verify import paths are correct
