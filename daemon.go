package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"
)

var daemonLogger *Logger

func runDaemon(config *Config) {
	daemonLogger = NewLogger(LogInfo)
	defer daemonLogger.Close()

	// Save PID file
	home, _ := os.UserHomeDir()
	cacheDir := filepath.Join(home, ".cache/gatekeeper")
	os.MkdirAll(cacheDir, 0755)
	pidFile := filepath.Join(cacheDir, "daemon.pid")
	pidBytes := []byte(fmt.Sprintf("%d", os.Getpid()))
	if err := os.WriteFile(pidFile, pidBytes, 0644); err != nil {
		daemonLogger.Warnf("Error saving PID file: %v", err)
	}
	defer os.Remove(pidFile)

	daemonLogger.Info("Gatekeeper daemon starting...")
	daemonLogger.Infof("Checking interval: %d seconds", config.Interval)
	daemonLogger.Infof("Found %d services to monitor", len(config.Services))

	ticker := time.NewTicker(time.Duration(config.Interval) * time.Second)
	defer ticker.Stop()

	// Handle signals for graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	// Run once immediately
	checkAndUpdateState(config)

	// Then run on interval
	for {
		select {
		case <-ticker.C:
			checkAndUpdateState(config)
		case sig := <-sigChan:
			daemonLogger.Infof("Received signal %v, shutting down gracefully", sig)
			return
		}
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
