package main

import (
	"fmt"
	"log"
	"os"
	"strings"
	"time"
)

// getUserHomeDir returns user home directory or exits with error message
func getUserHomeDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatalf("Error: Cannot determine home directory: %v\nThis may happen in restricted environments. Please set $HOME environment variable.", err)
	}
	return home
}

// getServiceIcon returns the icon for a service
// Uses custom icon if set, otherwise returns default icon based on service name
// Default icons use simple Unicode that works without special fonts
func getServiceIcon(serviceName, customIcon string) string {
	// Use custom icon if provided
	if customIcon != "" {
		return customIcon
	}

	// Default icons for common services
	// Using simple Unicode icons that work without Nerd Fonts
	nameLower := strings.ToLower(serviceName)

	// GitHub
	if strings.Contains(nameLower, "github") || strings.Contains(nameLower, "gh") {
		return "🐙"
	}

	// AWS
	if strings.Contains(nameLower, "aws") {
		return "☁️"
	}

	// GCP / Google Cloud
	if strings.Contains(nameLower, "gcp") || strings.Contains(nameLower, "google") {
		return "🌐"
	}

	// Docker
	if strings.Contains(nameLower, "docker") {
		return "🐳"
	}

	// Kubernetes
	if strings.Contains(nameLower, "kubernetes") || strings.Contains(nameLower, "k8s") {
		return "☸️"
	}

	// Azure
	if strings.Contains(nameLower, "azure") {
		return "☁️"
	}

	// No default icon
	return ""
}

// FormatCompact returns a tmux-friendly status string
// Example: " AWS:❌  GitHub:✅"
func FormatCompact(state *State) string {
	var parts []string
	for _, s := range state.Services {
		statusIcon := "✅"
		if !s.IsAlive {
			statusIcon = "❌"
		}

		// Include service icon if available
		if s.Icon != "" {
			parts = append(parts, fmt.Sprintf("%s %s:%s", s.Icon, s.Name, statusIcon))
		} else {
			parts = append(parts, fmt.Sprintf("%s:%s", s.Name, statusIcon))
		}
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
