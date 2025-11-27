package main

import (
	"context"
	"database/sql"
	"fmt"
)

type User struct {
	ID    string
	Email string
}

type UserRepository interface {
	FindByID(ctx context.Context, id string) (*User, error)
}

type PostgresUserRepository struct {
	db *sql.DB
}

func NewPostgresUserRepository(db *sql.DB) *PostgresUserRepository {
	return &PostgresUserRepository{db: db}
}

func (r *PostgresUserRepository) FindByID(ctx context.Context, id string) (*User, error) {
	var user User
	err := r.db.QueryRowContext(ctx, "SELECT id, email FROM users WHERE id = $1", id).
		Scan(&user.ID, &user.Email)
	if err != nil {
		return nil, fmt.Errorf("failed to query user: %w", err)
	}
	return &user, nil
}
