# Development Guide

## Local Setup

### Prerequisites
- Go 1.21+
- Xcode 15+ (for macOS app)
- git

### Building

#### Go CLI
```bash
# Build for current platform
go build -o gatekeeper

# Build for specific platforms
GOOS=linux GOARCH=amd64 go build -o dist/gatekeeper-linux-amd64
GOOS=darwin GOARCH=arm64 go build -o dist/gatekeeper-darwin-arm64
```

#### macOS App
```bash
cd GatekeeperApp
xcodebuild -scheme Gatekeeper -configuration Release build
```

### Testing

```bash
# Run all tests
go test -v ./...

# Run with coverage
go test -cover ./...
```

## Releasing

### Creating a Release

1. Update version in relevant files (README, etc)
2. Create a git tag:
   ```bash
   git tag -a v0.2.0 -m "Release v0.2.0: Description"
   git push origin v0.2.0
   ```

3. GitHub Actions will automatically:
   - Build binaries for all platforms
   - Create a GitHub Release with artifacts
   - Generate checksums
   - Create Homebrew formula
   - Submit PR to Homebrew/homebrew-core

### Manual Homebrew Publishing (if needed)

```bash
# Create formula
cat > /usr/local/Cellar/gatekeeper/formula.rb << EOF
# Formula content
EOF

# Or for tap-based homebrew
git clone https://github.com/retraut/homebrew-gatekeeper
# Update formula in Formula/gatekeeper.rb
git push
```

## GitHub Actions Workflows

### build.yml
- Triggers on push to master/main/develop and PRs
- Builds Go binaries for Linux/Darwin (amd64, arm64) and Windows
- Builds macOS app for both architectures
- Uploads artifacts for inspection

### release.yml
- Triggers on git tag push (v*)
- Builds all platform artifacts
- Generates SHA256 checksums
- Uploads to GitHub Release
- Auto-generates and uploads Homebrew formula
- Submits PR to Homebrew/homebrew-core

## Dependencies

### Go
```
gopkg.in/yaml.v3 v3.0.1
```

Update with:
```bash
go get -u
go mod tidy
```

## Code Structure

```
.
├── main.go              # CLI entry point
├── daemon.go            # Daemon loop
├── config.go            # Config parsing
├── state.go             # State management
├── checker.go           # Service health checks
├── webhooks.go          # Webhook integrations
├── health.go            # HTTP health endpoint
├── logger.go            # Structured logging
├── helpers.go           # Utility functions
├── GatekeeperApp/       # SwiftUI macOS app
└── GatekeeperSwift/     # Swift frameworks
```

## Contributing

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes and test locally
3. Push and create pull request
4. CI/CD will run tests and build artifacts
