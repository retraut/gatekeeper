package main

import (
	"fmt"
	"strings"
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
