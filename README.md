# Gatekeeper

Service authentication status monitor with daemon, CLI, and tmux integration.

Check if your AWS, GitHub, Docker, and other CLI tools are properly authenticated—all from one place.

**GitHub:** https://github.com/retraut/gatekeeper
**Releases:** https://github.com/retraut/gatekeeper/releases

## Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Installation](#installation)
  - [Homebrew (macOS)](#homebrew-macos)
  - [From GitHub Releases](#from-github-releases)
  - [From Source](#from-source)
- [Configuration](#configuration)
- [Quick Re-authentication](#quick-re-authentication)
- [Commands](#commands)
- [Shell Completions](#shell-completions)
- [Build Options](#build-options)
- [Integration](#integration)
  - [tmux](#tmux)
  - [macOS Auto-start](#macos-auto-start)
- [File Locations](#file-locations)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)
- [Contributing](#contributing)

## Quick Start

```bash
# 1. Install
./build.sh --cli --install

# 2. Configure
nano ~/.config/gatekeeper/config.yaml

# 3. Run
gatekeeper daemon

# 4. Check status
gatekeeper status --compact
```

## Features

- **Daemon** - Background process checking services on interval
- **CLI** - Check status anytime from terminal
- **Concurrent checks** - All services checked in parallel
- **Configurable timeouts** - Per-service timeout handling
- **Automatic retries** - Smart retry logic with exponential backoff
- **tmux integration** - Status in your tmux status bar
- **Shell completions** - Zsh auto-complete for services and commands
- **Quick auth** - One command to re-authenticate services
- **JSON state** - Single source of truth
- **Zero dependencies** - Only YAML parsing library

## Installation

### Homebrew (macOS)

```bash
brew tap retraut/gatekeeper
brew install gatekeeper
```

### From GitHub Releases

Download pre-built binaries:

```bash
# macOS (Apple Silicon)
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-darwin-arm64

# Linux (x86_64)
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-linux-amd64

# Linux (ARM64)
wget https://github.com/retraut/gatekeeper/releases/latest/download/gatekeeper-linux-arm64
```

Make executable and move to PATH:
```bash
chmod +x gatekeeper-darwin-arm64
mv gatekeeper-darwin-arm64 /usr/local/bin/gatekeeper
```

### From Source

```bash
git clone https://github.com/retraut/gatekeeper
cd gatekeeper
./build.sh --cli --install
```

## Configuration

Create config at `~/.config/gatekeeper/config.yaml`:

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

**Options:**
- `services` - List of services to monitor
- `interval` - Check interval in seconds (default: 30)
- `check_cmd` - Command to verify authentication (must exit 0 for success)
- `timeout` - Timeout per service in seconds (default: 5)
- `retries` - Number of retries (default: 1)

### Advanced Examples

**AWS with multiple profiles:**
```yaml
services:
  - name: AWS (production)
    check_cmd: "AWS_PROFILE=production aws sts get-caller-identity > /dev/null 2>&1"
    timeout: 10
    retries: 2

  - name: AWS (development)
    check_cmd: "AWS_PROFILE=development aws sts get-caller-identity > /dev/null 2>&1"
    timeout: 10
    retries: 2

  - name: AWS (staging)
    check_cmd: "AWS_PROFILE=staging aws sts get-caller-identity > /dev/null 2>&1"
    timeout: 10
    retries: 1
```

**Okta authentication:**
```yaml
services:
  - name: Okta
    check_cmd: "okta-aws-cli list-profiles > /dev/null 2>&1"
    timeout: 15
    retries: 1
```

**ArgoCD:**
```yaml
services:
  - name: ArgoCD
    check_cmd: "argocd account get-user-info > /dev/null 2>&1"
    timeout: 10
    retries: 2
```

**Docker:**
```yaml
services:
  - name: Docker
    check_cmd: "docker info > /dev/null 2>&1"
    timeout: 5
    retries: 1
```

**Kubernetes:**
```yaml
services:
  - name: Kubernetes (prod)
    check_cmd: "kubectl --context=prod-cluster cluster-info > /dev/null 2>&1"
    timeout: 10
    retries: 1

  - name: Kubernetes (dev)
    check_cmd: "kubectl --context=dev-cluster cluster-info > /dev/null 2>&1"
    timeout: 10
    retries: 1
```

**Google Cloud:**
```yaml
services:
  - name: GCP
    check_cmd: "gcloud auth list --filter=status:ACTIVE --format='value(account)' > /dev/null 2>&1"
    timeout: 10
    retries: 1
```

**Azure:**
```yaml
services:
  - name: Azure
    check_cmd: "az account show > /dev/null 2>&1"
    timeout: 10
    retries: 1
```

## Quick Re-authentication

When a service fails authentication, quickly re-authenticate with:

```bash
gatekeeper auth <service-name>
```

**Example:**
```yaml
# config.yaml
services:
  - name: GitHub
    check_cmd: "gh auth status > /dev/null 2>&1"
    auth_cmd: "gh auth login"

  - name: AWS
    check_cmd: "aws sts get-caller-identity > /dev/null 2>&1"
    auth_cmd: "aws sso login"

  - name: Docker
    check_cmd: "docker info > /dev/null 2>&1"
    auth_cmd: "docker login"
```

**Usage:**
```bash
# Check what's dead
$ gatekeeper status
AWS Production: ❌ dead
AWS Development: ❌ dead
GitHub: ✅ alive

# Re-auth single service (case-insensitive)
$ gatekeeper auth github
Running auth for 'GitHub'...
Logging into GitHub...
Auth completed for 'GitHub'

# Re-auth ALL AWS services at once (partial match)
$ gatekeeper auth aws
Found 2 services matching 'aws':
  - AWS Production
  - AWS Development

Running auth for all...

[1/2] Authenticating 'AWS Production'...
✓ Auth completed for 'AWS Production'

[2/2] Authenticating 'AWS Development'...
✓ Auth completed for 'AWS Development'

✓ All auth commands completed

# Re-auth EVERYTHING at once
$ gatekeeper auth all
Found 3 services matching 'all':
  - AWS Production
  - AWS Development
  - GitHub

Running auth for all...
[Progress for each service...]
✓ All auth commands completed
```

**Features:**
- **Case-insensitive** - `github`, `GitHub`, `GITHUB` all work
- **Partial matching** - `aws` matches all AWS services
- **Batch auth** - `auth all` or `auth aws` for multiple services
- **Interactive** - connects stdin/stdout for interactive auth flows
- **Smart matching** - shows available services if not found

## Commands

```bash
# Check status
gatekeeper status              # Human readable
gatekeeper status --compact    # For tmux
gatekeeper status --json       # JSON format

# Manage daemon
gatekeeper start               # Start daemon
gatekeeper stop                # Stop daemon

# Quick re-authentication
gatekeeper auth <service>      # Run auth command for service
gatekeeper auth GitHub         # Example: re-auth GitHub
gatekeeper auth AWS            # Example: re-auth AWS

# Other
gatekeeper init                # Create example config
gatekeeper --help              # Show help
```

## Shell Completions

Gatekeeper supports zsh completions with auto-complete for service names.

**Install:**
```bash
gatekeeper completion install
```

This will:
- Create `~/.zsh/completions/_gatekeeper`
- Auto-complete service names from your config
- Provide helpful descriptions for all commands

**What you get:**
```bash
gatekeeper <TAB>
# Shows: start, stop, status, auth, init, completion

gatekeeper auth <TAB>
# Shows: all, AWS Production, AWS Development, GitHub, etc.

gatekeeper status --<TAB>
# Shows: --json, --compact
```

**Uninstall:**
```bash
gatekeeper completion uninstall
```

**Setup (if not auto-detected):**

Add to `~/.zshrc`:
```bash
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
```

Then: `source ~/.zshrc`

## Build Options

```bash
./build.sh                    # Build CLI
./build.sh --cli              # CLI only
./build.sh --cli --install    # CLI + install
./build.sh --test             # Verify installation
./build.sh --clean            # Remove artifacts
./build.sh --help             # Show all options
```

## Integration

### tmux

Add to `~/.tmux.conf`:
```tmux
set -g status-right "#(gatekeeper status --compact)"
set -g status-interval 30
```

Reload:
```bash
tmux source-file ~/.tmux.conf
```

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| Binary | `~/.local/bin/gatekeeper` | Main CLI |
| Config | `~/.config/gatekeeper/config.yaml` | Service definitions |
| State | `~/.cache/gatekeeper/state.json` | Current status |
| Logs | `~/.cache/gatekeeper/gatekeeper.log` | Debug logs |

## Examples

**Check status:**
```bash
$ gatekeeper status
AWS: ✓ alive
GitHub: ✓ alive
```

**Compact format (for tmux):**
```bash
$ gatekeeper status --compact
AWS:✓ GitHub:✓
```

**JSON format (for apps/monitoring):**
```bash
$ gatekeeper status --json
{
  "services": [
    {"name": "AWS", "is_alive": true},
    {"name": "GitHub", "is_alive": true}
  ]
}
```

## Troubleshooting

**Command not found:**
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**Daemon not updating state:**
```bash
# Check if running
ps aux | grep gatekeeper

# Check logs
tail -f ~/.cache/gatekeeper/gatekeeper.log
```

**tmux not showing status:**
```bash
# Test command
gatekeeper status --compact

# Check path
which gatekeeper

# Reload tmux config
tmux source-file ~/.tmux.conf
```

**Build failed:**
```bash
go version  # Check Go is installed
go mod download
./build.sh --clean --cli
```

## Documentation

- **Build Guide** - [docs/build.md](docs/build.md)
- **Setup & Config** - [docs/setup.md](docs/setup.md)
- **Architecture** - [docs/architecture.md](docs/architecture.md)
- **All Docs** - [docs/](docs/)

## Contributing

This project uses **Conventional Commits** for automated versioning:

- `feat: Add new feature` → minor version bump
- `fix: Fix a bug` → patch version bump
- `feat!: Breaking change` → major version bump

See [docs/contributing.md](docs/contributing.md) for details.

## License

MIT
