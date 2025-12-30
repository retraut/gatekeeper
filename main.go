package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
)

func main() {
	// Subcommands
	statusCmd := flag.NewFlagSet("status", flag.ExitOnError)
	jsonFlag := statusCmd.Bool("json", false, "Output as JSON")
	compactFlag := statusCmd.Bool("compact", false, "Compact output for tmux")

	daemonCmd := flag.NewFlagSet("daemon", flag.ExitOnError)
	configPath := daemonCmd.String("config", "", "Path to config file (default: ~/.config/gatekeeper/config.yaml)")

	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	switch os.Args[1] {
	case "status":
		statusCmd.Parse(os.Args[2:])
		handleStatus(*jsonFlag, *compactFlag)

	case "daemon":
		daemonCmd.Parse(os.Args[2:])
		
		// Use default config path if not specified
		configFile := *configPath
		if configFile == "" {
			home, _ := os.UserHomeDir()
			configFile = filepath.Join(home, ".config/gatekeeper/config.yaml")
		}
		
		config, err := loadConfig(configFile)
		if err != nil {
			log.Fatalf("Error loading config from %s: %v", configFile, err)
		}
		runDaemon(config)

	case "init":
		handleInit()

	default:
		printUsage()
		os.Exit(1)
	}
}

func handleStatus(jsonOutput, compact bool) {
	state, err := loadState()
	if err != nil {
		log.Fatalf("Error loading state: %v", err)
	}

	if jsonOutput {
		data, _ := json.MarshalIndent(state, "", "  ")
		fmt.Println(string(data))
	} else if compact {
		fmt.Println(FormatCompact(state))
	} else {
		fmt.Print(FormatColored(state))
	}
}

func handleInit() {
	home, _ := os.UserHomeDir()
	configPath := filepath.Join(home, ".config", "gatekeeper", "config.yaml")

	// Create directory
	dir := filepath.Dir(configPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		log.Fatalf("Error creating directory: %v", err)
	}

	// Create example config
	example := `services:
  - name: AWS
    check_cmd: "aws sts get-caller-identity > /dev/null 2>&1"
    auth_cmd: "aws configure"
  - name: GitHub
    check_cmd: "gh auth status > /dev/null 2>&1"
    auth_cmd: "gh auth login"

interval: 30
`

	if err := os.WriteFile(configPath, []byte(example), 0644); err != nil {
		log.Fatalf("Error creating config: %v", err)
	}

	fmt.Printf("Config created at: %s\n", configPath)
}

func printUsage() {
	fmt.Println(`Gatekeeper - Service authentication status monitor

Usage:
  gatekeeper daemon [--config path]                   Start daemon (auto-uses ~/.config/gatekeeper/config.yaml)
  gatekeeper status [--json|--compact]                 Show current status
  gatekeeper init                                      Initialize config file

Examples:
  gatekeeper daemon                                    # Uses default config
  gatekeeper daemon --config /custom/path/config.yaml # Uses custom config
  gatekeeper status --compact
  gatekeeper status --json`)
}
