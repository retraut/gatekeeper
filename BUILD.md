# Gatekeeper Build Guide

## Quick Build (Recommended)

```bash
cd gatekeeper
./build.sh
```

This will:
1. ✅ Check requirements (Go, optional Xcode)
2. ✅ Build CLI binary
3. ✅ Build macOS app (if Xcode available)
4. ✅ Install to `~/.local/bin`
5. ✅ Create config at `~/.config/gatekeeper`
6. ✅ Test everything

## Build Scripts

### Main Build Script: `build.sh`

All-in-one build script with multiple options.

**Usage:**
```bash
./build.sh [options]
```

**Options:**
```
--all       Build & install everything (default, same as no args)
--cli       Build CLI binary only
--app       Build macOS app (requires Xcode)
--install   Install to ~/.local/bin
--test      Run installation tests
--clean     Remove build artifacts
--help      Show help
```

**Examples:**
```bash
./build.sh                      # Build everything
./build.sh --cli                # Just the CLI
./build.sh --clean --cli        # Clean then build
./build.sh --cli --install      # Build and install
```

### Old Install Script: `install.sh`

Legacy script that just builds and installs CLI.

```bash
chmod +x install.sh
./install.sh
```

Same as: `./build.sh --cli --install`

## Manual Build

### Build CLI Only

```bash
# Install dependencies
go mod download
go mod tidy

# Build
go build -o gatekeeper

# Test
./gatekeeper --help
./gatekeeper status
```

### Build macOS App

```bash
cd GatekeeperApp

# Option 1: Using Xcode GUI
open GatekeeperApp.xcodeproj
# Then: Product → Build (⌘B)

# Option 2: Using command line
xcodebuild -scheme Gatekeeper \
           -configuration Release \
           -derivedDataPath build \
           clean build

# Find built app at:
# GatekeeperApp/build/Release/Gatekeeper.app
```

See [GatekeeperApp/BUILD.md](GatekeeperApp/BUILD.md) for detailed app build instructions.

## Installation

### Install CLI

```bash
mkdir -p ~/.local/bin

# Copy binary
cp gatekeeper ~/.local/bin/

# Copy tmux helper
cp gatekeeper-tmux.sh ~/.local/bin/gatekeeper-tmux
chmod +x ~/.local/bin/gatekeeper-tmux

# Create config
./gatekeeper init
```

Or use the build script: `./build.sh --install`

### Install macOS App

After building:

```bash
# Copy app to Applications
cp -r GatekeeperApp/build/Release/Gatekeeper.app /Applications/

# Or open it from build directory
open GatekeeperApp/build/Release/Gatekeeper.app
```

### Add to Login Items (Auto-start)

```bash
# Option 1: Using script (if available)
launchctl load ~/Library/LaunchAgents/com.gatekeeper.daemon.plist

# Option 2: System Settings
# Settings → General → Login Items → Add Gatekeeper.app
```

## Troubleshooting

### Build Errors

**"Go is not installed"**
```bash
# Install Go from https://golang.org
brew install go  # Or download from golang.org
```

**"command not found: xcodebuild"**
```bash
# Install Xcode command line tools
xcode-select --install

# Or use full Xcode (more complete)
# Download from Mac App Store or https://developer.apple.com/download
```

**"cannot find package"**
```bash
cd gatekeeper
go mod download
go mod tidy
go build
```

### Installation Issues

**"Permission denied" when copying to ~/.local/bin**
```bash
mkdir -p ~/.local/bin
# Ensure directory is owned by you
ls -ld ~/.local/bin
```

**Binary not in PATH**
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

# Then source it
source ~/.zshrc
```

**App won't launch**
```bash
# Check code signature
codesign -v /Applications/Gatekeeper.app

# Sign it if needed
codesign -f -s - /Applications/Gatekeeper.app
```

### Testing

**Test CLI:**
```bash
gatekeeper --help
gatekeeper init
gatekeeper status
gatekeeper daemon --config ~/.config/gatekeeper/config.yaml
```

**Test installation:**
```bash
# Run the test
./build.sh --test
```

**Check binary:**
```bash
file ~/.local/bin/gatekeeper
ldd ~/.local/bin/gatekeeper  # Linux
otool -L ~/.local/bin/gatekeeper  # macOS
```

## Build Artifacts

### After Building CLI

```
gatekeeper/
├── gatekeeper          # Executable binary (~6MB)
└── (other files)
```

### After Building App

```
GatekeeperApp/
└── build/Release/
    └── Gatekeeper.app  # Complete app bundle
        ├── Contents/
        │   ├── MacOS/
        │   │   └── Gatekeeper        # Executable
        │   ├── Resources/
        │   │   ├── Assets.car
        │   │   └── ...
        │   ├── Info.plist
        │   ├── PkgInfo
        │   └── ...
```

## Platform-Specific Notes

### macOS

```bash
# Check OS version
sw_vers

# Minimum requirement: macOS 11.0+

# Full Xcode vs Command Line Tools
# Command Line Tools: ~500MB, CLI only
# Xcode: ~15GB, IDE + SDK + simulators
```

### Linux (if porting)

```bash
# Install Go
sudo apt-get install golang-go

# Build
go build -o gatekeeper

# Install
sudo cp gatekeeper /usr/local/bin/
```

### Windows (if porting)

```powershell
# Install Go from https://golang.org

# Build
go build -o gatekeeper.exe

# Install manually or create installer
```

## Advanced Options

### Optimize Binary Size

```bash
# Strip debug symbols
go build -ldflags="-s -w" -o gatekeeper

# UPX compression (optional)
upx --best gatekeeper
```

Result: ~5.9MB → ~2.5MB

### Build for Different Architectures

```bash
# ARM64 (Apple Silicon)
GOARCH=arm64 go build -o gatekeeper-arm64

# x86_64 (Intel)
GOARCH=amd64 go build -o gatekeeper-amd64

# Universal binary (both)
lipo -create gatekeeper-arm64 gatekeeper-amd64 -output gatekeeper-universal
```

### Static Binary (no dependencies)

```bash
CGO_ENABLED=0 go build -o gatekeeper-static
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build
on: push

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - run: ./build.sh --cli
      - uses: actions/upload-artifact@v3
        with:
          name: gatekeeper
          path: gatekeeper
```

## Version Management

Add version to build:

```bash
VERSION=$(git describe --tags --always)
go build -ldflags="-X main.Version=$VERSION"
```

Then in Go code:

```go
var Version = "dev"

func main() {
    if os.Args[1] == "version" {
        fmt.Println(Version)
    }
}
```

## Distribution

### Create Release Package

```bash
# Create tarball
tar -czf gatekeeper-v1.0.0-macos.tar.gz \
    gatekeeper \
    gatekeeper-tmux.sh \
    config.yaml.example \
    README.md

# Create zip
zip gatekeeper-v1.0.0-macos.zip \
    gatekeeper \
    gatekeeper-tmux.sh \
    config.yaml.example \
    README.md
```

### Build All Platforms

```bash
# macOS
GOOS=darwin GOARCH=amd64 go build -o gatekeeper-darwin-amd64
GOOS=darwin GOARCH=arm64 go build -o gatekeeper-darwin-arm64

# Linux
GOOS=linux GOARCH=amd64 go build -o gatekeeper-linux-amd64
GOOS=linux GOARCH=arm64 go build -o gatekeeper-linux-arm64

# Windows
GOOS=windows GOARCH=amd64 go build -o gatekeeper-windows-amd64.exe
```

## Development Setup

### Hot Reload Development

```bash
# Watch for changes and rebuild
go install github.com/cosmtrek/air@latest
air

# Or use entr
find . -name "*.go" | entr -r bash -c 'go build && ./gatekeeper daemon'
```

### Testing

```bash
# Run tests (if any)
go test ./...

# With coverage
go test -cover ./...

# Integration test
./gatekeeper daemon &
sleep 2
./gatekeeper status --json
pkill gatekeeper
```

---

**For more help:**
- Run: `./build.sh --help`
- Check: [SETUP.md](SETUP.md)
- Check: [GatekeeperApp/BUILD.md](GatekeeperApp/BUILD.md)
