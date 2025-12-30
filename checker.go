package main

import (
	"os/exec"
)

type ServiceStatus struct {
	Name    string `json:"name"`
	IsAlive bool   `json:"is_alive"`
	Error   string `json:"error,omitempty"`
}

func checkService(service Service) ServiceStatus {
	status := ServiceStatus{
		Name: service.Name,
	}

	// Try check_cmd first
	if service.CheckCmd != "" {
		cmd := exec.Command("bash", "-c", service.CheckCmd)
		if err := cmd.Run(); err == nil {
			status.IsAlive = true
			return status
		}
	}

	// Fallback to auth_cmd
	if service.AuthCmd != "" {
		cmd := exec.Command("bash", "-c", service.AuthCmd)
		if err := cmd.Run(); err != nil {
			status.Error = err.Error()
		} else {
			status.IsAlive = true
			return status
		}
	}

	status.IsAlive = false
	return status
}
