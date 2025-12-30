package main

import (
	"encoding/json"
	"os"
	"path/filepath"
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
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".cache", "gatekeeper", "state.json")
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
