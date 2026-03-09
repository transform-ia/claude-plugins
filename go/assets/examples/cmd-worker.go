package main

import (
	"context"
	"fmt"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/spf13/cobra"
)

func workerCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "worker",
		Short: "Start background worker",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runWorker(cmd.Context())
		},
	}
}

func runWorker(ctx context.Context) error {
	cfg, err := LoadConfig()
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	// OTel metrics are MANDATORY for all long-running applications.
	// Workers without an existing HTTP server MUST create one for
	// /health and /metrics exposition.
	metricsHandler, shutdownMetrics, err := InitMetrics("myworker")
	if err != nil {
		return fmt.Errorf("failed to init metrics: %w", err)
	}
	defer shutdownMetrics()

	mux := http.NewServeMux()
	mux.Handle("/health", HealthHandler())
	mux.Handle("/metrics", metricsHandler)

	server := &http.Server{
		Addr:    fmt.Sprintf(":%d", cfg.HTTPPort),
		Handler: mux,
	}

	go func() {
		if err := server.ListenAndServe(); err != http.ErrServerClosed {
			// log error
		}
	}()

	ctx, stop := signal.NotifyContext(ctx, syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	// ... worker loop using ctx ...
	<-ctx.Done()

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	return server.Shutdown(shutdownCtx)
}
