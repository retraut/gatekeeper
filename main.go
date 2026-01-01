package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
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

	case "start":
		daemonCmd.Parse(os.Args[2:])
		
		// Use default config path if not specified
		configFile := *configPath
		if configFile == "" {
			home := getUserHomeDir()
			configFile = filepath.Join(home, ".config/gatekeeper/config.yaml")
		}
		
		config, err := loadConfig(configFile)
		if err != nil {
			log.Fatalf("Error loading config from %s: %v", configFile, err)
		}
		runDaemon(config)

	case "init":
		handleInit()

	case "stop":
		handleStop()

	case "auth":
		if len(os.Args) < 3 {
			fmt.Println("Usage: gatekeeper auth <service-name|all>")
			os.Exit(1)
		}
		handleAuth(os.Args[2])

	case "completion":
		if len(os.Args) < 3 {
			fmt.Println("Usage: gatekeeper completion <install|uninstall>")
			os.Exit(1)
		}
		handleCompletion(os.Args[2])

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
	home := getUserHomeDir()
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

func handleStop() {
	home := getUserHomeDir()
	pidFile := filepath.Join(home, ".cache/gatekeeper/daemon.pid")

	pidBytes, err := os.ReadFile(pidFile)
	if err != nil {
		fmt.Println("Daemon not running (no PID file found)")
		return
	}

	var pid int
	if _, err := fmt.Sscanf(string(pidBytes), "%d", &pid); err != nil || pid <= 0 {
		fmt.Println("Invalid PID file")
		os.Remove(pidFile)
		return
	}

	// Find the process
	process, err := os.FindProcess(pid)
	if err != nil {
		fmt.Printf("Process %d not found (already stopped)\n", pid)
		os.Remove(pidFile)
		return
	}

	// Send interrupt signal
	err = process.Signal(os.Interrupt)
	if err != nil {
		fmt.Printf("Process %d already stopped\n", pid)
		os.Remove(pidFile)
		return
	}

	fmt.Printf("Stopping daemon (PID %d)...\n", pid)

	// Wait for PID file to be removed by daemon (up to 3 seconds)
	for i := 0; i < 30; i++ {
		time.Sleep(100 * time.Millisecond)
		if _, err := os.Stat(pidFile); os.IsNotExist(err) {
			fmt.Println("Daemon stopped successfully")
			return
		}
	}

	// If still running after 3 seconds, force kill
	fmt.Println("Daemon didn't stop gracefully, forcing...")
	process.Kill()
	os.Remove(pidFile)
	fmt.Println("Daemon stopped (forced)")
}

func handleAuth(serviceName string) {
	// Load config
	home := getUserHomeDir()
	configFile := filepath.Join(home, ".config/gatekeeper/config.yaml")

	config, err := loadConfig(configFile)
	if err != nil {
		log.Fatalf("Error loading config: %v", err)
	}

	// Find matching services (case-insensitive, partial match)
	var matchedServices []Service
	searchLower := strings.ToLower(serviceName)

	// Special case: "all" matches all services with auth_cmd
	if searchLower == "all" {
		for _, svc := range config.Services {
			if svc.AuthCmd != "" {
				matchedServices = append(matchedServices, svc)
			}
		}
	} else {
		for _, svc := range config.Services {
			nameLower := strings.ToLower(svc.Name)
			// Exact match or partial match
			if nameLower == searchLower || strings.Contains(nameLower, searchLower) {
				if svc.AuthCmd != "" {
					matchedServices = append(matchedServices, svc)
				}
			}
		}
	}

	if len(matchedServices) == 0 {
		fmt.Printf("No services found matching '%s'\n", serviceName)
		fmt.Println("\nAvailable services:")
		for _, svc := range config.Services {
			if svc.AuthCmd != "" {
				fmt.Printf("  - %s\n", svc.Name)
			}
		}
		os.Exit(1)
	}

	// Execute auth for all matched services
	if len(matchedServices) == 1 {
		fmt.Printf("Running auth for '%s'...\n", matchedServices[0].Name)
	} else {
		fmt.Printf("Found %d services matching '%s':\n", len(matchedServices), serviceName)
		for _, svc := range matchedServices {
			fmt.Printf("  - %s\n", svc.Name)
		}
		fmt.Println("\nRunning auth for all...")
	}

	for i, svc := range matchedServices {
		if len(matchedServices) > 1 {
			fmt.Printf("\n[%d/%d] Authenticating '%s'...\n", i+1, len(matchedServices), svc.Name)
		}

		cmd := exec.Command("sh", "-c", svc.AuthCmd)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		if err := cmd.Run(); err != nil {
			fmt.Printf("Auth failed for '%s': %v\n", svc.Name, err)
			continue
		}

		if len(matchedServices) > 1 {
			fmt.Printf("✓ Auth completed for '%s'\n", svc.Name)
		}
	}

	if len(matchedServices) == 1 {
		fmt.Printf("Auth completed for '%s'\n", matchedServices[0].Name)
	} else {
		fmt.Printf("\n✓ All auth commands completed\n")
	}
}

func handleCompletion(action string) {
	home := getUserHomeDir()
	zshCompletionPath := filepath.Join(home, ".zsh/completions/_gatekeeper")
	zshrcPath := filepath.Join(home, ".zshrc")

	switch strings.ToLower(action) {
	case "install":
		// Create completions directory
		completionsDir := filepath.Dir(zshCompletionPath)
		if err := os.MkdirAll(completionsDir, 0755); err != nil {
			fmt.Printf("Error creating completions directory: %v\n", err)
			os.Exit(1)
		}

		// Generate completion script
		completionScript := generateZshCompletion()

		// Write completion script
		if err := os.WriteFile(zshCompletionPath, []byte(completionScript), 0644); err != nil {
			fmt.Printf("Error writing completion script: %v\n", err)
			os.Exit(1)
		}

		fmt.Printf("✓ Installed zsh completion to: %s\n", zshCompletionPath)

		// Check if fpath is configured in .zshrc
		zshrcContent, _ := os.ReadFile(zshrcPath)
		if !strings.Contains(string(zshrcContent), "fpath=(~/.zsh/completions $fpath)") {
			fmt.Println("\nAdd this to your ~/.zshrc:")
			fmt.Println("  fpath=(~/.zsh/completions $fpath)")
			fmt.Println("  autoload -Uz compinit && compinit")
			fmt.Println("\nThen restart your shell or run: source ~/.zshrc")
		} else {
			fmt.Println("\nRestart your shell or run: source ~/.zshrc")
		}

	case "uninstall":
		if _, err := os.Stat(zshCompletionPath); os.IsNotExist(err) {
			fmt.Println("Completion not installed")
			os.Exit(0)
		}

		if err := os.Remove(zshCompletionPath); err != nil {
			fmt.Printf("Error removing completion: %v\n", err)
			os.Exit(1)
		}

		fmt.Printf("✓ Removed zsh completion from: %s\n", zshCompletionPath)

	default:
		fmt.Printf("Unknown action '%s'. Use 'install' or 'uninstall'\n", action)
		os.Exit(1)
	}
}

func generateZshCompletion() string {
	// Load config to get service names for completion
	home := getUserHomeDir()
	configFile := filepath.Join(home, ".config/gatekeeper/config.yaml")

	var serviceNames []string
	if config, err := loadConfig(configFile); err == nil {
		for _, svc := range config.Services {
			serviceNames = append(serviceNames, svc.Name)
		}
	}

	servicesStr := ""
	if len(serviceNames) > 0 {
		for _, name := range serviceNames {
			servicesStr += fmt.Sprintf("    '%s:Auth for %s'\n", name, name)
		}
	}

	return `#compdef gatekeeper

_gatekeeper() {
  local -a commands
  commands=(
    'start:Start the daemon'
    'stop:Stop the daemon'
    'status:Show service status'
    'auth:Authenticate a service'
    'init:Initialize config file'
    'completion:Manage shell completions'
  )

  local -a status_flags
  status_flags=(
    '--json:Output as JSON'
    '--compact:Compact output for tmux'
  )

  local -a auth_services
  auth_services=(
    'all:Authenticate all services'
` + servicesStr + `
  )

  local -a completion_actions
  completion_actions=(
    'install:Install zsh completion'
    'uninstall:Remove zsh completion'
  )

  if (( CURRENT == 2 )); then
    _describe 'command' commands
  else
    case "$words[2]" in
      status)
        _describe 'flag' status_flags
        ;;
      auth)
        _describe 'service' auth_services
        ;;
      completion)
        _describe 'action' completion_actions
        ;;
    esac
  fi
}

_gatekeeper "$@"
`
}

const Version = "0.7.1"

func printUsage() {
	fmt.Printf("Gatekeeper v%s - Service authentication status monitor\n", Version)
	fmt.Println(`

Usage:
  gatekeeper start [--config path]                    Start daemon (auto-uses ~/.config/gatekeeper/config.yaml)
  gatekeeper stop                                      Stop daemon
  gatekeeper status [--json|--compact]                 Show current status
  gatekeeper auth <service-name|all>                   Run auth command for service(s)
  gatekeeper completion <install|uninstall>            Manage zsh completions
  gatekeeper init                                      Initialize config file

Examples:
  gatekeeper start                                     # Uses default config
  gatekeeper start --config /custom/path/config.yaml  # Uses custom config
  gatekeeper stop
  gatekeeper status --compact
  gatekeeper status --json
  gatekeeper auth github                               # Auth GitHub (case-insensitive)
  gatekeeper auth aws                                  # Auth all AWS services
  gatekeeper auth all                                  # Auth all services
  gatekeeper completion install                        # Install zsh completions`)
}
