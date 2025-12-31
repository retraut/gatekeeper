package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"
)

const (
	maxLogSize = 10 * 1024 * 1024 // 10MB
)

type LogLevel int

const (
	LogDebug LogLevel = iota
	LogInfo
	LogWarn
	LogError
)

var logLevelName = map[LogLevel]string{
	LogDebug: "DEBUG",
	LogInfo:  "INFO",
	LogWarn:  "WARN",
	LogError: "ERROR",
}

type Logger struct {
	level   LogLevel
	file    *os.File
	logger  *log.Logger
	logPath string
}

func NewLogger(level LogLevel) *Logger {
	home, _ := os.UserHomeDir()
	logDir := filepath.Join(home, ".cache", "gatekeeper")
	os.MkdirAll(logDir, 0755)

	logPath := filepath.Join(logDir, "gatekeeper.log")
	f, err := os.OpenFile(logPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		log.Fatal(err)
	}

	return &Logger{
		level:   level,
		file:    f,
		logger:  log.New(f, "", 0),
		logPath: logPath,
	}
}

func (l *Logger) rotate() {
	info, err := l.file.Stat()
	if err != nil {
		return
	}

	if info.Size() < maxLogSize {
		return
	}

	l.file.Close()

	oldPath := l.logPath + ".old"
	os.Remove(oldPath)
	os.Rename(l.logPath, oldPath)

	f, err := os.OpenFile(l.logPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		return
	}

	l.file = f
	l.logger = log.New(f, "", 0)
}

func (l *Logger) log(level LogLevel, msg string) {
	if level < l.level {
		return
	}
	l.rotate()
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	l.logger.Printf("[%s] %s: %s", timestamp, logLevelName[level], msg)
}

func (l *Logger) Debug(msg string) {
	l.log(LogDebug, msg)
}

func (l *Logger) Info(msg string) {
	l.log(LogInfo, msg)
}

func (l *Logger) Warn(msg string) {
	l.log(LogWarn, msg)
}

func (l *Logger) Error(msg string) {
	l.log(LogError, msg)
}

func (l *Logger) Debugf(format string, args ...interface{}) {
	l.log(LogDebug, fmt.Sprintf(format, args...))
}

func (l *Logger) Infof(format string, args ...interface{}) {
	l.log(LogInfo, fmt.Sprintf(format, args...))
}

func (l *Logger) Warnf(format string, args ...interface{}) {
	l.log(LogWarn, fmt.Sprintf(format, args...))
}

func (l *Logger) Errorf(format string, args ...interface{}) {
	l.log(LogError, fmt.Sprintf(format, args...))
}

func (l *Logger) Close() {
	if l.file != nil {
		l.file.Close()
	}
}
