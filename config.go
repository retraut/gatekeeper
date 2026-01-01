package main

import (
	"os"

	"gopkg.in/yaml.v3"
)

type Service struct {
	Name     string `yaml:"name"`
	CheckCmd string `yaml:"check_cmd"`
	AuthCmd  string `yaml:"auth_cmd"`
	Timeout  int    `yaml:"timeout"`  // seconds
	Retries  int    `yaml:"retries"`
}

type Config struct {
	Services []Service `yaml:"services"`
	Interval int       `yaml:"interval"` // seconds
}

func loadConfig(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var config Config
	if err := yaml.Unmarshal(data, &config); err != nil {
		return nil, err
	}

	// Default interval if not specified
	if config.Interval == 0 {
		config.Interval = 30
	}

	// Validate interval bounds
	if config.Interval < 5 {
		config.Interval = 5
	} else if config.Interval > 3600 {
		config.Interval = 3600
	}

	return &config, nil
}
