# Gatekeeper CLI

Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI.

## Phase 1: Skeleton & Configuration ✅

- [x] Project initialization (`go mod init`)
- [x] Config parser (YAML)
- [x] Core daemon loop
- [x] State manager (JSON cache)
- [x] CLI skeleton

## Quick Start

```bash
# Download dependencies
go mod download

# Initialize config
go run . init

# Start daemon
go run . daemon

# Check status (in another terminal)
go run . status --compact
go run . status --json
```

## Config Format

```yaml
services:
  - name: AWS
    check_cmd: "aws sts get-caller-identity > /dev/null 2>&1"
    auth_cmd: "aws configure"

interval: 30  # seconds
```

## Commands

- `daemon [--config path]` - Start checking services on interval
- `status [--json|--compact]` - Show current status
- `init` - Create example config at `~/.config/gatekeeper/config.yaml`

## Phase 2: Engine Enhancements ✅

- [x] Structured logging with levels (DEBUG, INFO, WARN, ERROR)
- [x] Timeout handling for commands (configurable per-service)
- [x] Retry logic with exponential backoff
- [x] Concurrent service checks (batch processing)
- [x] on_failure actions (run command when service goes down)
- [x] HTTP health check endpoint (`/health`, `/status`)
- [x] Environment variable expansion in commands
- [x] Better error handling and reporting

### New Config Options

```yaml
services:
  - name: AWS
    check_cmd: "aws sts get-caller-identity > /dev/null 2>&1"
    timeout: 10        # seconds
    retries: 2         # number of attempts
    on_failure: "notify-team"  # optional command to run on failure

interval: 30
health_port: 8080   # Optional HTTP health endpoint
```

### Logs

Logs are written to `~/.cache/gatekeeper/gatekeeper.log` with timestamps and levels.

### Health Endpoint

If configured, access health status:

```bash
curl http://localhost:8080/health    # Overall health
curl http://localhost:8080/status    # Detailed service status
```

## Phase 3: tmux Integration ✅

### Installation

```bash
chmod +x install.sh
./install.sh
```

This installs:
- `~/.local/bin/gatekeeper` - main binary
- `~/.local/bin/gatekeeper-tmux` - tmux helper script

### tmux Setup

Add to your `~/.tmux.conf`:

```tmux
set -g status-right "#(~/.local/bin/gatekeeper-tmux) | #(date '+%%H:%%M')"
set -g status-interval 10
```

Reload tmux:
```bash
tmux source-file ~/.tmux.conf
```

### How it works

- `gatekeeper daemon` runs in background, updating `~/.cache/gatekeeper/state.json` every 30 seconds
- tmux calls `gatekeeper-tmux` which runs `gatekeeper status --compact`
- Status appears in tmux status-right: `AWS:❌ GitHub:✅`

### Launch on macOS startup

```bash
cp launch-agent.plist ~/Library/LaunchAgents/com.gatekeeper.daemon.plist
# Edit paths in plist if needed
launchctl load ~/Library/LaunchAgents/com.gatekeeper.daemon.plist
```

## Phase 4: macOS GUI (SwiftUI) & WidgetKit ✅

### MenuBar App

SwiftUI app that runs in system menu bar showing service status at a glance.

**Features:**
- Displays status icon (🔐) in menu bar
- Click to open popover with:
  - Service status list with live indicators
  - Quick actions: Start Daemon, Edit Config, View Logs
  - Auto-refresh every 10 seconds
- Runs as background app (no dock icon)

**Build:**
```bash
cd GatekeeperApp
open GatekeeperApp.xcodeproj
# Build with Xcode or:
xcodebuild -scheme Gatekeeper -configuration Release build
```

### WidgetKit (Desktop & Lock Screen)

Interactive widgets that display on macOS desktop or lock screen.

**Available Sizes:**
- **Small**: Status indicator (✅/⚠️)
- **Medium**: Service list with live status
- **Large**: Detailed view with counters and full service list

**How to add:**
1. Run Gatekeeper app from menu bar
2. Right-click on desktop → Edit Widgets
3. Search for "Gatekeeper" and add widget(s)
4. Widgets auto-refresh every 30 seconds

### Architecture

```
┌──────────────────────────────────┐
│      go daemon (CLI)             │
│  Updates ~/.cache/gatekeeper/    │
│           state.json             │
│  every 30 seconds                │
└────────────┬──────────────────────┘
             │
             ↓ (reads)
    ┌────────────────────┐
    │  state.json        │
    │  (JSON file)       │
    └─────────┬──────────┘
              │
        ┌─────┴─────┐
        ↓           ↓
    ┌────────┐  ┌──────────┐
    │ MenuBar│  │ WidgetKit│
    │  App   │  │ Widgets  │
    └────────┘  └──────────┘
    (every 10s) (every 30s)
```

### Data Flow

- **Go daemon** checks services, writes to `~/.cache/gatekeeper/state.json`
- **MenuBar app** reads state every 10 seconds, displays in menu bar
- **WidgetKit** reads state every 30 seconds, updates desktop/lock screen widgets
- All three operate independently, zero coupling

See [GatekeeperApp/BUILD.md](GatekeeperApp/BUILD.md) for detailed build instructions.
