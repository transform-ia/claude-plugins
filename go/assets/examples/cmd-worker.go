package main

import (
	"time"

	"github.com/transform-ia/gokit"
	"go.uber.org/zap"
)

type WorkerConfig struct {
	QueueURL string `envconfig:"QUEUE_URL" required:"true" validate:"required"`
}

func runWorker(ctx *gokit.Context[WorkerConfig]) error {
	ctx.Logger.Ctx(ctx).Info("worker starting", zap.String("queue", ctx.Config.QueueURL))

	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			ctx.Logger.Ctx(ctx).Info("worker shutting down")
			return nil
		case <-ticker.C:
			// Process work...
		}
	}
}
