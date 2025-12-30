package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

// FormatCompact returns a tmux-friendly status string
// Example: "AWS:❌ GitHub:✅"
func FormatCompact(state *State) string {
	var parts []string
	for _, s := range state.Services {
		icon := "✅"
		if !s.IsAlive {
			icon = "❌"
		}
		parts = append(parts, fmt.Sprintf("%s:%s", s.Name, icon))
	}
	return strings.Join(parts, " ")
}

// FormatColored returns a colored output for terminal display
func FormatColored(state *State) string {
	var output strings.Builder
	
	// Daemon status
	daemonStatus := "not running"
	daemonColor := "\033[31m"  // red
	if state.Daemon != nil && state.Daemon.Running {
		daemonStatus = fmt.Sprintf("running (PID %d, uptime %s)", state.Daemon.PID, formatUptime(state.Daemon.StartedAt))
		daemonColor = "\033[32m"  // green
	}
	output.WriteString(fmt.Sprintf("Daemon: %s%s\033[0m\n", daemonColor, daemonStatus))
	
	if state.Daemon != nil && state.Daemon.Running {
		output.WriteString(fmt.Sprintf("Last check: %s\n\n", state.Daemon.LastCheck.Format("15:04:05")))
	}
	
	// Services
	for _, s := range state.Services {
		status := "✅ alive"
		color := "\033[32m"  // green
		if !s.IsAlive {
			status = "❌ dead"
			color = "\033[31m"  // red
		}
		output.WriteString(fmt.Sprintf("%s%s\033[0m: %s\n", color, s.Name, status))
	}
	return output.String()
}

// formatUptime returns human-readable uptime
func formatUptime(startTime time.Time) string {
	duration := time.Since(startTime).Round(time.Second)
	hours := int(duration.Hours())
	minutes := int(duration.Minutes()) % 60
	seconds := int(duration.Seconds()) % 60
	
	if hours > 0 {
		return fmt.Sprintf("%dh%dm", hours, minutes)
	} else if minutes > 0 {
		return fmt.Sprintf("%dm%ds", minutes, seconds)
	}
	return fmt.Sprintf("%ds", seconds)
}

// isDaemonRunning checks if daemon is actually running
func isDaemonRunning() bool {
	home, _ := os.UserHomeDir()
	pidFile := filepath.Join(home, ".cache/gatekeeper/daemon.pid")
	
	pidBytes, err := os.ReadFile(pidFile)
	if err != nil {
		return false
	}
	
	pid, err := strconv.Atoi(strings.TrimSpace(string(pidBytes)))
	if err != nil || pid == 0 {
		return false
	}
	
	// Try to find process
	_, err = os.FindProcess(pid)
	return err == nil
}
