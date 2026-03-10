package main

import (
	"context"
	"fmt"

	"github.com/uptrace/opentelemetry-go-extra/otelzap"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/metric"
	"go.uber.org/zap"
)

var (
	userFetchCounter, _ = otel.Meter("myapp").Int64Counter(
		"myapp_user_fetch_total",
		metric.WithDescription("Total user fetch operations"),
	)
)

type UserService struct {
	repo   UserRepository
	logger *otelzap.Logger
}

func NewUserService(repo UserRepository, logger *otelzap.Logger) *UserService {
	return &UserService{repo: repo, logger: logger}
}

func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
	ctx, span := otel.Tracer("myapp").Start(ctx, "UserService.GetUser")
	defer span.End()

	span.SetAttributes(attribute.String("user.id", id))
	userFetchCounter.Add(ctx, 1, metric.WithAttributes(
		attribute.String("method", "GetUser"),
	))

	s.logger.Ctx(ctx).Info("fetching user", zap.String("user_id", id))

	user, err := s.repo.FindByID(ctx, id)
	if err != nil {
		span.RecordError(err)
		span.SetStatus(codes.Error, err.Error())
		return nil, fmt.Errorf("failed to find user %s: %w", id, err)
	}
	return user, nil
}
