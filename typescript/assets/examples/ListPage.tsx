// src/pages/Items/ItemList.tsx
// Example CRUD list page with filtering, pagination, and delete
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, gql } from '@apollo/client';
import {
  Box,
  Grid,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  InputAdornment,
  Tabs,
  Tab,
  Snackbar,
  Alert,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import {
  PageHeader,
  LoadingSpinner,
  ErrorAlert,
  EmptyState,
  ConfirmDialog,
} from '../../components';

const GET_ITEMS = gql`
  query GetItems($where: items_bool_exp, $orderBy: [items_order_by!], $limit: Int, $offset: Int) {
    items(where: $where, order_by: $orderBy, limit: $limit, offset: $offset) {
      id
      name
      status
      created_at
    }
    items_aggregate(where: $where) {
      aggregate {
        count
      }
    }
  }
`;

const DELETE_ITEM = gql`
  mutation DeleteItem($id: uuid!) {
    delete_items_by_pk(id: $id) {
      id
    }
  }
`;

export function ItemList() {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [sortBy, setSortBy] = useState('created_desc');
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [snackbar, setSnackbar] = useState<{
    open: boolean;
    message: string;
    severity: 'success' | 'error';
  }>({ open: false, message: '', severity: 'success' });

  // Build query variables based on filters
  const getOrderBy = () => {
    switch (sortBy) {
      case 'name_asc': return [{ name: 'asc' }];
      case 'name_desc': return [{ name: 'desc' }];
      case 'created_asc': return [{ created_at: 'asc' }];
      default: return [{ created_at: 'desc' }];
    }
  };

  const getWhere = () => {
    const conditions: Record<string, unknown>[] = [];
    if (statusFilter !== 'all') {
      conditions.push({ status: { _eq: statusFilter } });
    }
    if (searchTerm.trim()) {
      conditions.push({ name: { _ilike: `%${searchTerm}%` } });
    }
    return conditions.length > 0 ? { _and: conditions } : {};
  };

  const { data, loading, error, refetch } = useQuery(GET_ITEMS, {
    variables: {
      where: getWhere(),
      orderBy: getOrderBy(),
      limit: 50,
      offset: 0,
    },
  });

  const [deleteItem] = useMutation(DELETE_ITEM, {
    onCompleted: () => {
      setSnackbar({ open: true, message: 'Item deleted', severity: 'success' });
      refetch();
    },
    onError: (err) => {
      setSnackbar({ open: true, message: err.message, severity: 'error' });
    },
  });

  const handleDelete = () => {
    if (deleteId) {
      deleteItem({ variables: { id: deleteId } });
      setDeleteId(null);
    }
  };

  if (error) return <ErrorAlert message={error.message} onRetry={() => refetch()} />;

  const items = data?.items || [];
  const totalCount = data?.items_aggregate?.aggregate?.count || 0;

  return (
    <Box>
      <PageHeader
        title="Items"
        subtitle={`${totalCount} item${totalCount !== 1 ? 's' : ''}`}
        actionLabel="New Item"
        onAction={() => navigate('/items/new')}
      />

      {/* Filters */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid size={{ xs: 12, sm: 6, md: 4 }}>
          <TextField
            fullWidth
            placeholder="Search..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon />
                </InputAdornment>
              ),
            }}
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <FormControl fullWidth size="small">
            <InputLabel>Sort By</InputLabel>
            <Select value={sortBy} label="Sort By" onChange={(e) => setSortBy(e.target.value)}>
              <MenuItem value="created_desc">Newest First</MenuItem>
              <MenuItem value="created_asc">Oldest First</MenuItem>
              <MenuItem value="name_asc">Name A-Z</MenuItem>
              <MenuItem value="name_desc">Name Z-A</MenuItem>
            </Select>
          </FormControl>
        </Grid>
      </Grid>

      {/* Content */}
      {loading ? (
        <LoadingSpinner message="Loading items..." />
      ) : items.length === 0 ? (
        <EmptyState
          title="No items found"
          description="Create your first item to get started"
          actionLabel="Create Item"
          onAction={() => navigate('/items/new')}
        />
      ) : (
        <Grid container spacing={2}>
          {/* Render items here */}
        </Grid>
      )}

      {/* Delete Confirmation */}
      <ConfirmDialog
        open={!!deleteId}
        title="Delete Item"
        message="Are you sure you want to delete this item?"
        confirmLabel="Delete"
        confirmColor="error"
        onConfirm={handleDelete}
        onCancel={() => setDeleteId(null)}
      />

      {/* Snackbar */}
      <Snackbar
        open={snackbar.open}
        autoHideDuration={4000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert severity={snackbar.severity}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
}
