package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"time"
)

type WebhookPayload struct {
	Service   string    `json:"service"`
	Status    string    `json:"status"` // "up" or "down"
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
	Error     string    `json:"error,omitempty"`
}

// SendWebhook sends a notification to a webhook URL
func SendWebhook(webhookURL string, payload WebhookPayload) error {
	data, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", webhookURL, bytes.NewBuffer(data))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	return nil
}

// SendSlackMessage sends a message to a Slack webhook
func SendSlackMessage(webhookURL, service string, isAlive bool) error {
	var color string
	var text string

	if isAlive {
		color = "good"
		text = "✅ Service is now available"
	} else {
		color = "danger"
		text = "❌ Service is down"
	}

	payload := map[string]interface{}{
		"attachments": []map[string]interface{}{
			{
				"color": color,
				"title": service,
				"text":  text,
				"ts":    time.Now().Unix(),
			},
		},
	}

	data, _ := json.Marshal(payload)

	req, _ := http.NewRequest("POST", webhookURL, bytes.NewBuffer(data))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 5 * time.Second}
	_, _ = client.Do(req)

	return nil
}
