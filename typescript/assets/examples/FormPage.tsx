// src/pages/Items/ItemForm.tsx
// Example CRUD form page with validation
import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, gql } from '@apollo/client';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  Box,
  Card,
  CardContent,
  Grid,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
  Snackbar,
  Alert,
} from '@mui/material';
import SaveIcon from '@mui/icons-material/Save';
import { PageHeader, LoadingSpinner, ErrorAlert } from '../../components';

// Zod schema for form validation
const itemSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  description: z.string().optional(),
  status: z.enum(['active', 'inactive', 'pending']),
});

type ItemFormData = z.infer<typeof itemSchema>;

const GET_ITEM = gql`
  query GetItem($id: uuid!) {
    items_by_pk(id: $id) {
      id
      name
      description
      status
    }
  }
`;

const CREATE_ITEM = gql`
  mutation CreateItem($input: items_insert_input!) {
    insert_items_one(object: $input) {
      id
    }
  }
`;

const UPDATE_ITEM = gql`
  mutation UpdateItem($id: uuid!, $input: items_set_input!) {
    update_items_by_pk(pk_columns: { id: $id }, _set: $input) {
      id
    }
  }
`;

export function ItemForm() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const isEdit = !!id;
  const [snackbar, setSnackbar] = useState<{
    open: boolean;
    message: string;
    severity: 'success' | 'error';
  }>({ open: false, message: '', severity: 'success' });

  // Fetch existing item for edit mode
  const { data, loading, error } = useQuery(GET_ITEM, {
    variables: { id },
    skip: !isEdit,
  });

  // Mutations
  const [createItem, { loading: createLoading }] = useMutation(CREATE_ITEM, {
    onCompleted: (data) => navigate(`/items/${data.insert_items_one.id}`),
    onError: (err) => setSnackbar({ open: true, message: err.message, severity: 'error' }),
  });

  const [updateItem, { loading: updateLoading }] = useMutation(UPDATE_ITEM, {
    onCompleted: () => navigate(`/items/${id}`),
    onError: (err) => setSnackbar({ open: true, message: err.message, severity: 'error' }),
  });

  // Form setup with react-hook-form and zod
  const {
    control,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<ItemFormData>({
    resolver: zodResolver(itemSchema),
    defaultValues: {
      name: '',
      description: '',
      status: 'pending',
    },
  });

  // Populate form with existing data
  useEffect(() => {
    if (data?.items_by_pk) {
      reset(data.items_by_pk);
    }
  }, [data, reset]);

  const onSubmit = (formData: ItemFormData) => {
    const input = {
      name: formData.name,
      description: formData.description || null,
      status: formData.status,
    };

    if (isEdit) {
      updateItem({ variables: { id, input } });
    } else {
      createItem({ variables: { input } });
    }
  };

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorAlert message={error.message} />;

  return (
    <Box>
      <PageHeader
        title={isEdit ? 'Edit Item' : 'New Item'}
        breadcrumbs={[
          { label: 'Items', path: '/items' },
          { label: isEdit ? 'Edit' : 'New' },
        ]}
      />

      <form onSubmit={handleSubmit(onSubmit)}>
        <Card sx={{ maxWidth: 600 }}>
          <CardContent>
            <Grid container spacing={2}>
              <Grid size={12}>
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
              </Grid>

              <Grid size={12}>
                <Controller
                  name="description"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Description"
                      fullWidth
                      multiline
                      rows={4}
                    />
                  )}
                />
              </Grid>

              <Grid size={12}>
                <Controller
                  name="status"
                  control={control}
                  render={({ field }) => (
                    <FormControl fullWidth>
                      <InputLabel>Status</InputLabel>
                      <Select {...field} label="Status">
                        <MenuItem value="pending">Pending</MenuItem>
                        <MenuItem value="active">Active</MenuItem>
                        <MenuItem value="inactive">Inactive</MenuItem>
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>
            </Grid>
          </CardContent>
        </Card>

        <Box sx={{ display: 'flex', gap: 2, mt: 3 }}>
          <Button variant="outlined" onClick={() => navigate('/items')}>
            Cancel
          </Button>
          <Button
            type="submit"
            variant="contained"
            startIcon={<SaveIcon />}
            disabled={createLoading || updateLoading}
          >
            {createLoading || updateLoading ? 'Saving...' : 'Save'}
          </Button>
        </Box>
      </form>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={4000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert severity={snackbar.severity}>{snackbar.message}</Alert>
      </Snackbar>
    </Box>
  );
}
