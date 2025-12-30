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

	if err := saveState(state); err != nil {
		daemonLogger.Errorf("Error saving state: %v", err)
	}
}
