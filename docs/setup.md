# Gatekeeper Complete Setup Guide

## Quick Start (5 minutes)

### 1. Build & Install CLI

```bash
cd /path/to/gatekeeper
chmod +x install.sh
./install.sh
```

This installs:
- `~/.local/bin/gatekeeper` - Main binary
- `~/.local/bin/gatekeeper-tmux` - tmux helper
- `~/.config/gatekeeper/config.yaml` - Config file (edit this!)

### 2. Edit Config

```bash
nano ~/.config/gatekeeper/config.yaml
```

Example:
```yaml
services:
  - name: AWS
    check_cmd: "aws sts get-caller-identity > /dev/null 2>&1"
    timeout: 10
    retries: 2
  
  - name: GitHub
    check_cmd: "gh auth status > /dev/null 2>&1"
    timeout: 10
    retries: 1

interval: 30
```

### 3. Start Daemon

```bash
# Manual (for testing)
gatekeeper daemon

# Auto-start on login (macOS)
cp launch-agent.plist ~/Library/LaunchAgents/com.gatekeeper.daemon.plist
launchctl load ~/Library/LaunchAgents/com.gatekeeper.daemon.plist

# Check status
gatekeeper status
gatekeeper status --json
gatekeeper status --compact
```

## Integration: tmux

Add to `~/.tmux.conf`:

```tmux
set -g status-right "#(~/.local/bin/gatekeeper-tmux) | #(date '+%%H:%%M')"
set -g status-interval 10
```

Reload:
```bash
tmux source-file ~/.tmux.conf
```

Status appears in tmux: `AWS:❌ GitHub:✅`

## Integration: macOS GUI

### MenuBar App

```bash
cd GatekeeperApp
open GatekeeperApp.xcodeproj
```

1. In Xcode, set your development team
2. Build: Product → Build
3. Run: Product → Run

**To auto-launch on login:**
- System Settings → General → Login Items → Add Gatekeeper.app

### WidgetKit

After building the app:

1. Right-click desktop → Edit Widgets
2. Click + to add widget
3. Search for "Gatekeeper"
4. Choose size (Small/Medium/Large) and add

## Monitoring

### CLI Status
```bash
gatekeeper status              # Pretty output
gatekeeper status --json       # JSON format
gatekeeper status --compact    # tmux format
```

### Logs
```bash
tail -f ~/.cache/gatekeeper/gatekeeper.log
```

## Advanced Config

### Per-Service Timeouts
```yaml
services:
  - name: SlowService
    check_cmd: "slow-command"
    timeout: 30        # 30 seconds (default 10)
    retries: 3         # Retry 3 times
```

## Troubleshooting

### Daemon not updating state
```bash
# Check daemon is running
ps aux | grep gatekeeper

# Check logs
tail -f ~/.cache/gatekeeper/gatekeeper.log

# Restart manually
gatekeeper daemon
```

### CLI shows "Unable to load state"
- Ensure daemon has run at least once
- Check if file exists: `cat ~/.cache/gatekeeper/state.json`

### Widgets show old data
- Ensure daemon is running
- Force refresh: Long-press widget → Edit

### tmux integration not working
- Verify binary path: `which gatekeeper`
- Test directly: `gatekeeper status --compact`
- Check tmux config: `tmux show-options -g status-right`

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| Binary | `~/.local/bin/gatekeeper` | Main CLI |
| Config | `~/.config/gatekeeper/config.yaml` | Service definitions |
| State | `~/.cache/gatekeeper/state.json` | Current status (read by UI) |
| Logs | `~/.cache/gatekeeper/gatekeeper.log` | Debug logs |
| LaunchAgent | `~/Library/LaunchAgents/com.gatekeeper.daemon.plist` | Auto-start config |

## Environment Variables

```bash
GATEKEEPER_BIN=/path/to/gatekeeper  # Override binary path in tmux script
```

## Next Steps

1. Edit `~/.config/gatekeeper/config.yaml` with your services
2. Start daemon: `gatekeeper daemon`
3. Add to tmux: Edit `~/.tmux.conf`
4. Build macOS app: Open `GatekeeperApp/GatekeeperApp.xcodeproj`
5. Add widgets: Right-click desktop → Edit Widgets → Add Gatekeeper
