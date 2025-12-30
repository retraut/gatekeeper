package main

import (
	"context"
	"time"
)

var daemonLogger *Logger

func runDaemon(config *Config) {
	daemonLogger = NewLogger(LogInfo)
	defer daemonLogger.Close()

	daemonLogger.Info("Gatekeeper daemon starting...")
	daemonLogger.Infof("Checking interval: %d seconds", config.Interval)
	daemonLogger.Infof("Found %d services to monitor", len(config.Services))

	// Start health check HTTP server if configured
	if config.HealthPort != "" {
		daemonLogger.Infof("Starting health check server on port %s", config.HealthPort)
		StartHealthServer(config.HealthPort)
	}

	ticker := time.NewTicker(time.Duration(config.Interval) * time.Second)
	defer ticker.Stop()

	// Run once immediately
	checkAndUpdateState(config)

	// Then run on interval
	for range ticker.C {
		checkAndUpdateState(config)
	}
}

func checkAndUpdateState(config *Config) {
	ctx := context.Background()
	state := &State{}

	// Create checker with enhanced features
	checker := NewEnhancedChecker(CheckerOptions{
		Logger:  daemonLogger,
		Retries: 1,
	})

	// Check all services concurrently
	statuses := checker.CheckBatch(ctx, config.Services)
	state.Services = statuses

	// Update health endpoint state
	UpdateLastState(state)

	// Handle webhooks and on_failure actions
	for i, service := range config.Services {
		status := statuses[i]
		
		if !status.IsAlive && service.OnFailure != "" {
			daemonLogger.Warnf("[%s] Running on_failure action", service.Name)
			cmd := NewEnhancedChecker(CheckerOptions{Logger: daemonLogger})
			cmd.runCommand(ctx, service.OnFailure)
		}
	}

	if err := saveState(state); err != nil {
		daemonLogger.Errorf("Error saving state: %v", err)
	}
}
