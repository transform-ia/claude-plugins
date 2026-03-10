package main

import (
	"net/http"

	"github.com/transform-ia/gokit"
)

type ServeConfig struct {
	Port        int    `envconfig:"PORT" default:"8080" validate:"required"`
	DatabaseURL string `envconfig:"DATABASE_URL" required:"true" validate:"required"`
}

func routes(ctx *gokit.Context[ServeConfig]) []gokit.Route {
	// gokit automatically registers /health and /metrics.
	return []gokit.Route{
		{Pattern: "/api/users", Handler: usersHandler(ctx)},
	}
}

func usersHandler(ctx *gokit.Context[ServeConfig]) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx.Logger.Ctx(r.Context()).Info("handling users request")
		w.WriteHeader(http.StatusOK)
	})
}
