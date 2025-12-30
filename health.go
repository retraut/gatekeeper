package main

import (
	"encoding/json"
	"net/http"
	"sync"
	"time"
)

type HealthCheckResponse struct {
	Status    string           `json:"status"` // "healthy" or "degraded"
	Timestamp time.Time        `json:"timestamp"`
	Services  []ServiceStatus  `json:"services"`
	Uptime    string           `json:"uptime"`
}

var (
	lastState *State
	stateMutex sync.RWMutex
	startTime time.Time
)

func init() {
	startTime = time.Now()
}

// UpdateLastState updates the cached state for health checks
func UpdateLastState(state *State) {
	stateMutex.Lock()
	defer stateMutex.Unlock()
	lastState = state
}

// StartHealthServer starts HTTP health check server on given port
func StartHealthServer(port string) {
	http.HandleFunc("/health", handleHealth)
	http.HandleFunc("/status", handleStatusEndpoint)
	go http.ListenAndServe(":"+port, nil)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	stateMutex.RLock()
	defer stateMutex.RUnlock()

	if lastState == nil {
		w.WriteHeader(http.StatusServiceUnavailable)
		json.NewEncoder(w).Encode(map[string]string{
			"status": "unavailable",
		})
		return
	}

	// Check if all services are up
	allHealthy := true
	for _, s := range lastState.Services {
		if !s.IsAlive {
			allHealthy = false
			break
		}
	}

	status := "healthy"
	code := http.StatusOK
	if !allHealthy {
		status = "degraded"
		code = http.StatusPartialContent
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(HealthCheckResponse{
		Status:    status,
		Timestamp: time.Now(),
		Services:  lastState.Services,
		Uptime:    time.Since(startTime).String(),
	})
}

func handleStatusEndpoint(w http.ResponseWriter, r *http.Request) {
	stateMutex.RLock()
	defer stateMutex.RUnlock()

	w.Header().Set("Content-Type", "application/json")
	if lastState != nil {
		json.NewEncoder(w).Encode(lastState)
	} else {
		w.WriteHeader(http.StatusServiceUnavailable)
		json.NewEncoder(w).Encode(map[string]string{"error": "no state available"})
	}
}
