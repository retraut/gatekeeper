package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"syscall"
	"time"
)

type State struct {
	Daemon   *DaemonStatus  `json:"daemon"`
	Services []ServiceStatus `json:"services"`
}

type DaemonStatus struct {
	Running   bool      `json:"running"`
	PID       int       `json:"pid"`
	StartedAt time.Time `json:"started_at"`
	LastCheck time.Time `json:"last_check"`
}

func getStatePath() string {
	home := getUserHomeDir()
	return filepath.Join(home, ".cache", "gatekeeper", "state.json")
}

// isProcessRunning checks if a process with given PID exists
func isProcessRunning(pid int) bool {
	if pid <= 0 {
		return false
	}

	// Try to find the process
	process, err := os.FindProcess(pid)
	if err != nil {
		return false
	}

	// Send signal 0 to check if process exists (doesn't actually send anything)
	// On Unix systems, signal 0 can be used to check process existence
	err = process.Signal(syscall.Signal(0))
	return err == nil
}

func loadState() (*State, error) {
	path := getStatePath()
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return &State{}, nil
		}
		return nil, err
	}

	var state State
	if err := json.Unmarshal(data, &state); err != nil {
		return nil, err
	}

	// Verify daemon is actually running if state says it is
	if state.Daemon != nil && state.Daemon.Running {
		if !isProcessRunning(state.Daemon.PID) {
			// Process not running, update state
			state.Daemon.Running = false
			// Save corrected state back to file
			saveState(&state)
		}
	}

	return &state, nil
}

func saveState(state *State) error {
	path := getStatePath()
	dir := filepath.Dir(path)

	// Create directory if it doesn't exist
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}

	data, err := json.MarshalIndent(state, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(path, data, 0644)
}
