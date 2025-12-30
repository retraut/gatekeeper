# Gatekeeper

Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI.

Check if your AWS, GitHub, Docker, and other CLI tools are properly authenticated—all from one place.

**GitHub:** https://github.com/retraut/gatekeeper  
**Releases:** https://github.com/retraut/gatekeeper/releases

## Features

- **Daemon** - Background process checking services on interval
- **CLI** - Check status anytime from terminal
- **Concurrent checks** - All services checked in parallel
- **Configurable timeouts** - Per-service timeout handling
- **Automatic retries** - Smart retry logic with exponential backoff
- **tmux integration** - Status in your tmux status bar
- **macOS Menu Bar** - Native SwiftUI app showing status at a glance
- **WidgetKit** - Desktop and Lock Screen widgets
- **JSON state** - Single source of truth
- **Zero dependencies** - Only YAML parsing library

## Installation

### Homebrew (macOS)

```bash
brew tap retraut/gatekeeper
brew install gatekeeper
```

Or one-liner:
```bash
brew install retraut/gatekeeper/gatekeeper
```

### From GitHub Releases

Download pre-built binaries for your platform:

```bash
# macOS (Intel)
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-darwin-amd64

# macOS (Apple Silicon)
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-darwin-arm64

# Linux (x86_64)
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-linux-amd64

# Linux (ARM64)
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-linux-arm64

# Windows
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-windows-amd64.exe
```

Then move to your PATH:
```bash
chmod +x gatekeeper-darwin-arm64
mv gatekeeper-darwin-arm64 /usr/local/bin/gatekeeper
```

**Verify integrity:** Each binary has an associated `.sha256` file for verification:
```bash
# Download both files
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-darwin-arm64
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-darwin-arm64.sha256

# Verify
sha256sum -c gatekeeper-darwin-arm64.sha256
```

### From Source

```bash
git clone https://github.com/retraut/gatekeeper
cd gatekeeper
go build -o gatekeeper
mv gatekeeper /usr/local/bin/
```

## Quick Start

### 1. Create Config

```bash
mkdir -p ~/.config/gatekeeper
cat > ~/.config/gatekeeper/config.yaml << 'EOF'
services:
  - name: AWS
    check_cmd: "aws sts get-caller-identity > /dev/null 2>&1"
  - name: GitHub
    check_cmd: "gh auth status > /dev/null 2>&1"

interval: 30
EOF
```

### 2. Start Daemon

```bash
gatekeeper daemon
```

### 3. Check Status

In another terminal:
```bash
gatekeeper status
gatekeeper status --compact
gatekeeper status --json
```

## Configuration

Config file location: `~/.config/gatekeeper/config.yaml`

**Basic example:**
```yaml
services:
  - name: AWS
    check_cmd: "aws sts get-caller-identity > /dev/null 2>&1"
    timeout: 10
    retries: 2

interval: 30
```

**Options:**
- `services` - List of services to monitor
- `interval` - Check interval in seconds (default: 30)
- `check_cmd` - Command to verify authentication (must exit 0 for success)
- `timeout` - Timeout per service in seconds (default: 5)
- `retries` - Number of retries (default: 1)

## Commands

```bash
gatekeeper daemon [--config path]   # Start daemon
gatekeeper status                   # Show status
gatekeeper status --compact         # Compact format
gatekeeper status --json            # JSON format
gatekeeper init                     # Create example config
gatekeeper --help                   # Show help
```

## Integration

### tmux

Add to `~/.tmux.conf`:
```tmux
set -g status-right "#(gatekeeper status --compact)"
set -g status-interval 30
```

Then reload:
```bash
tmux source-file ~/.tmux.conf
```

### Launch on macOS Startup

```bash
cp launch-agent.plist ~/Library/LaunchAgents/com.gatekeeper.daemon.plist
launchctl load ~/Library/LaunchAgents/com.gatekeeper.daemon.plist
```

### macOS Menu Bar App

For full macOS GUI (MenuBar app + Widgets):

```bash
cd GatekeeperApp
xcodebuild -scheme Gatekeeper -configuration Release build
```

Then drag the built app to Applications.

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| Binary | `~/.local/bin/gatekeeper` | Main CLI |
| Config | `~/.config/gatekeeper/config.yaml` | Service definitions |
| State | `~/.cache/gatekeeper/state.json` | Current status |
| Logs | `~/.cache/gatekeeper/gatekeeper.log` | Debug logs |

## Documentation

- **Getting Started** - [docs/01-getting-started.md](docs/01-getting-started.md)
- **Build Guide** - [docs/build.md](docs/build.md)
- **Architecture** - [docs/architecture.md](docs/architecture.md)
- **Setup & Config** - [docs/setup.md](docs/setup.md)
- **All Docs** - [docs/](docs/)

## Troubleshooting

**"Command not found: gatekeeper"**
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**"Build failed"**
```bash
go mod download
go build -o gatekeeper
```

**"Daemon not updating state"**
```bash
ps aux | grep gatekeeper
tail -f ~/.cache/gatekeeper/gatekeeper.log
```

## Contributing

This project uses **Conventional Commits** for automated versioning.

When committing, use the format:
- `feat: Add new feature` → triggers minor version bump
- `fix: Fix a bug` → triggers patch version bump
- `feat!: Breaking change` → triggers major version bump

See [docs/contributing.md](docs/contributing.md) for more details.

## License

MIT
