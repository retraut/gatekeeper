# Gatekeeper Architecture

## System Overview

```
                    SERVICE MONITORING
                    
┌─────────────────────────────────────────────┐
│         Go Daemon (gatekeeper)              │
│                                             │
│  • Reads ~/config.yaml                      │
│  • Runs check commands concurrently         │
│  • Handles retries, timeouts, logs          │
│  • Writes to ~/.cache/gatekeeper/state.json│
│                                             │
│                                             │
│  Runs every N seconds (configurable)        │
└──────────────┬──────────────────────────────┘
               │
               │ writes every 30s
               ↓
      ┌────────────────────┐
      │   state.json       │
      │                    │
      │ {                  │
      │   "services": [    │
      │     {              │
      │       "name": "X", │
      │       "is_alive":  │
      │       true/false   │
      │     }              │
      │   ]                │
      │ }                  │
      └────────┬───────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    │ reads               │ reads
    │ on demand           │ every 30s
    ↓                     ↓
 ┌────────┐           ┌────────┐
 │  CLI   │           │ tmux   │
 │ status │           │ Status │
 │ (Go)   │           │(Bash)  │
 └────────┘           └────────┘
     │                    │
   Shows               Shows
   status on           status in
   terminal            tmux bar
```

## Component Breakdown

### 1. Go Daemon (Core)

**Files:**
- `main.go` - CLI entry point
- `config.go` - YAML parsing
- `checker_enhanced.go` - Timeouts, retries, concurrency
- `daemon.go` - Main loop
- `logger.go` - Structured logging
- `state.go` - State persistence
- `helpers.go` - Formatting utilities

**Flow:**
```
1. Load config.yaml
2. For each interval:
   a. Run all service checks concurrently
   b. Save to state.json
   c. Log results
```

**State Machine:**
```
┌──────────┐
│ Idle     │
└────┬─────┘
     │ timer tick
     ↓
┌──────────────────┐
│ Check Services   │
│ (concurrent)     │
└────┬─────────────┘
     │
     ├→ Retry logic (per service)
     ├→ Timeout handling (per service)
     ├→ Log results
     │
     ↓
┌──────────────────┐
│ Save state.json  │
└────┬─────────────┘
     │
     ↓ repeat
```

### 2. tmux Integration (Bash)

**Files:**
- `gatekeeper-tmux.sh` - Status formatter

**Flow:**
```
tmux status-right command
    ↓
Executes: gatekeeper status --compact
    ↓
Reads ~/.cache/gatekeeper/state.json
    ↓
Outputs: "AWS:❌ GitHub:✅"
    ↓
Displayed in tmux status bar
```

## Data Models

### Service (Config)
```yaml
name: string          # Display name
check_cmd: string     # Primary check command
auth_cmd: string      # Fallback if check_cmd fails
timeout: int          # Seconds (default: 10)
retries: int          # Attempts (default: 1)
```

### ServiceStatus (State)
```json
{
  "name": "AWS",
  "is_alive": false,
  "error": "exit status 255"
}
```

### Config (Root)
```yaml
services: []          # Array of Service
interval: int         # Check interval in seconds
```

## Concurrency Model

### Daemon Checks
```
Main Loop (sequential)
    ↓ every N seconds
Concurrent.CheckBatch()
    ├─ Goroutine 1: Check Service A (timeout: 10s)
    ├─ Goroutine 2: Check Service B (timeout: 10s)
    ├─ Goroutine 3: Check Service C (timeout: 10s)
    └─ WaitGroup: Wait for all to complete
    ↓
Save results atomically
```

### UI Refresh
- **CLI**: On-demand (when user runs `gatekeeper status`)
- **tmux**: Interval-based (configured via `status-interval`)

## Failure Handling

### Command Timeouts
```
For each service:
  1. Start command with context timeout
  2. If timeout exceeded → ctx.Done() cancels
  3. Return error status
  4. Retry if configured
```

### Retry Logic
```
For each service:
  attempt = 1..retries:
    1. Run check command
    2. If success → return alive
    3. If fail and attempt < retries:
       - Wait 2 seconds
       - Try again
    4. If all retries exhausted → return dead
```

### Logging
```
Each attempt logged to ~/.cache/gatekeeper/gatekeeper.log
Format: [TIMESTAMP] LEVEL: [SERVICE] message

Examples:
[2025-12-30 17:51:49] INFO: [GitHub] ✅ check passed (attempt 1/1)
[2025-12-30 17:51:50] ERROR: [AWS] ❌ check failed after 2 attempts
```

## File System Layout

```
~/.config/gatekeeper/
    └─ config.yaml              # Configuration (read-only by daemon)

~/.cache/gatekeeper/
    ├─ state.json              # Current status (written by daemon, read by UI)
    └─ gatekeeper.log          # Debug logs (append-only)

~/.local/bin/
    ├─ gatekeeper              # Main binary
    └─ gatekeeper-tmux         # tmux helper script

~/Library/LaunchAgents/
    └─ com.gatekeeper.daemon.plist  # Auto-start config
```

## Performance Characteristics

| Component | Refresh Rate | Latency | CPU | Memory |
|-----------|-------------|---------|-----|--------|
| Daemon | N seconds (config) | ~1-10s per check | Low | ~5-10MB |
| CLI | On demand | <100ms | Minimal | <1MB |
| tmux | Configured interval | <100ms | Minimal | <1MB |

## Security Considerations

1. **State File Permissions**: `~/.cache/gatekeeper/state.json` is world-readable
   - Contains only status info (no credentials)
   - Consider restricting if needed: `chmod 600 state.json`

2. **Command Execution**: All commands run with user privileges
   - No privilege escalation
   - No injection handling (user controls config)

3. **Logs**: Written to user home directory
   - May contain command errors/stack traces
   - Rotate or archive periodically

## Extension Points

### Add New UI
1. Read `~/.cache/gatekeeper/state.json`
2. Parse JSON to State struct
3. Display/refresh as needed

### Custom Checks
1. Modify `checker_enhanced.go` command execution
2. Add parsing/validation logic
