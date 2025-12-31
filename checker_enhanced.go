package main

import (
	"context"
	"os"
	"os/exec"
	"time"
)

const DefaultTimeout = 10 * time.Second

type ServiceStatus struct {
	Name    string `json:"name"`
	IsAlive bool   `json:"is_alive"`
	Error   string `json:"error,omitempty"`
}

type CheckerOptions struct {
	Timeout time.Duration
	Retries int
	Logger  *Logger
}

type EnhancedChecker struct {
	opts CheckerOptions
}

func NewEnhancedChecker(opts CheckerOptions) *EnhancedChecker {
	if opts.Timeout == 0 {
		opts.Timeout = DefaultTimeout
	}
	if opts.Retries == 0 {
		opts.Retries = 1
	}
	return &EnhancedChecker{opts: opts}
}

// CheckWithContext executes command with timeout and retry logic
func (c *EnhancedChecker) CheckWithContext(ctx context.Context, service Service) ServiceStatus {
	status := ServiceStatus{
		Name: service.Name,
	}

	// Try with retries
	for attempt := 1; attempt <= c.opts.Retries; attempt++ {
		if c.executeCheck(ctx, service, &status) {
			status.IsAlive = true
			if c.opts.Logger != nil {
				c.opts.Logger.Infof("[%s] ✅ check passed (attempt %d/%d)", 
					service.Name, attempt, c.opts.Retries)
			}
			return status
		}

		if attempt < c.opts.Retries {
			if c.opts.Logger != nil {
				c.opts.Logger.Warnf("[%s] check failed, retrying... (attempt %d/%d)", 
					service.Name, attempt, c.opts.Retries)
			}
			time.Sleep(2 * time.Second)
		}
	}

	status.IsAlive = false
	if c.opts.Logger != nil {
		c.opts.Logger.Errorf("[%s] ❌ check failed after %d attempts", 
			service.Name, c.opts.Retries)
	}
	return status
}

func (c *EnhancedChecker) executeCheck(ctx context.Context, service Service, status *ServiceStatus) bool {
	// Run check_cmd
	if service.CheckCmd != "" {
		if c.runCommand(ctx, service.CheckCmd) {
			return true
		}
		status.Error = "check failed"
	}

	return false
}

func (c *EnhancedChecker) runCommand(ctx context.Context, cmdStr string) bool {
	ctx, cancel := context.WithTimeout(ctx, c.opts.Timeout)
	defer cancel()

	// Expand environment variables
	cmdStr = os.ExpandEnv(cmdStr)

	cmd := exec.CommandContext(ctx, "bash", "-c", cmdStr)
	cmd.Stdout = nil
	cmd.Stderr = nil

	return cmd.Run() == nil
}

// CheckBatch runs multiple checks concurrently
func (c *EnhancedChecker) CheckBatch(ctx context.Context, services []Service) []ServiceStatus {
	results := make([]ServiceStatus, len(services))
	done := make(chan int, len(services))

	for i, svc := range services {
		go func(idx int, s Service) {
			results[idx] = c.CheckWithContext(ctx, s)
			done <- idx
		}(i, svc)
	}

	// Wait for all checks to complete
	for range services {
		<-done
	}

	return results
}
