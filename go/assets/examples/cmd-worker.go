package main

import (
	"github.com/transform-ia/gokit"
	"go.uber.org/zap"
)

type WorkerConfig struct {
	Port     int    `envconfig:"PORT" default:"8080" validate:"required"`
	QueueURL string `envconfig:"QUEUE_URL" required:"true" validate:"required"`
}

func runWorker(ctx *gokit.Context[WorkerConfig]) error {
	ctx.Logger.Ctx(ctx).Info("worker starting", zap.String("queue", ctx.Config.QueueURL))

	for {
		select {
		case <-ctx.Done():
			ctx.Logger.Ctx(ctx).Info("worker shutting down")
			return nil
		default:
			// Process work...
		}
	}
}
