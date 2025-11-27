package main

import (
	"context"
	"fmt"

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

	// ... worker setup
	_ = cfg
	return nil
}
