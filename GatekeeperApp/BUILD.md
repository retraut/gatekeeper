# Building Gatekeeper macOS App

## Requirements
- macOS 11.0+
- Xcode 13+
- Swift 5.5+

## Build Steps

### 1. Open in Xcode

```bash
open GatekeeperApp.xcodeproj
```

### 2. Configure Project Settings

In Xcode:
1. Select the project in the navigator
2. Select "Gatekeeper" target
3. Set your development team
4. Update Bundle Identifier (e.g., `com.yourname.gatekeeper`)

### 3. Build

```bash
# Command line
xcodebuild -scheme Gatekeeper -configuration Release build

# Or use Xcode directly
# Product → Build
```

### 4. Run

```bash
# From Xcode
Product → Run

# Or launch built app
./build/Release/Gatekeeper.app/Contents/MacOS/Gatekeeper
```

## How It Works

### MenuBar App (Gatekeeper.swift)
- Runs as background app (LSUIElement = true)
- Shows status icon in system menu bar (🔐)
- Displays popover with:
  - List of services and their status
  - Quick actions: Start Daemon, Edit Config, View Logs, Quit
- Auto-refreshes status every 10 seconds by reading `~/.cache/gatekeeper/state.json`

### WidgetKit (GatekeeperWidget.swift)
- Adds widgets to Lock Screen and Desktop
- Three sizes available:
  - **Small**: Status indicator only
  - **Medium**: Service list with status
  - **Large**: Detailed status with counters
- Refreshes every 30 seconds (reads from same JSON state file)

## Data Flow

```
go daemon                    (updates every 30s)
    ↓
~/.cache/gatekeeper/state.json
    ↓
├── MenuBar App (reads every 10s)
└── WidgetKit (refreshes every 30s)
```

## Installation on macOS

### Auto-launch
To auto-launch the app on login:

```bash
# Build app
xcodebuild -scheme Gatekeeper -configuration Release build

# Add to Login Items (System Settings > General > Login Items)
# Or use:
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/path/to/Gatekeeper.app", hidden:false}'
```

### Manual Launch
```bash
open -a Gatekeeper
```

## Troubleshooting

**Widget shows "Unable to load service status"**
- Ensure daemon is running: `gatekeeper daemon`
- Check if state file exists: `cat ~/.cache/gatekeeper/state.json`

**MenuBar icon not appearing**
- Check System Preferences > Dock & Menu Bar
- Restart the app

**App crashes on launch**
- Check logs: `log stream --predicate 'process == "Gatekeeper"'`
- Ensure go binary path is correct in code

## Development Notes

- State is read-only from SwiftUI (no writing back to daemon)
- All service checking is done by the Go daemon only
- SwiftUI app is purely for visualization
- File system access requires appropriate permissions
