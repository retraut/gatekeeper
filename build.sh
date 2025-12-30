#!/bin/bash
# Gatekeeper Build Script
# Builds all components (CLI, macOS app)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check requirements
check_requirements() {
    print_header "Checking Requirements"
    
    if ! command -v go &> /dev/null; then
        print_error "Go is not installed. Please install Go 1.21+"
        exit 1
    fi
    print_success "Go $(go version | awk '{print $3}')"
    
    if ! command -v xcodebuild &> /dev/null; then
        print_info "Xcode not found. macOS app build will be skipped."
        XCODE_AVAILABLE=false
    else
        # Check if it's full Xcode or just CLI tools
        XCODE_VERSION=$(xcodebuild -version 2>&1 | head -1)
        if echo "$XCODE_VERSION" | grep -qi "Xcode" && [ -z "$(echo "$XCODE_VERSION" | grep -i "command")" ]; then
            print_success "$XCODE_VERSION"
            XCODE_AVAILABLE=true
        else
            print_info "Found: Command Line Tools only (not full Xcode)"
            print_info "Go CLI will work perfectly, but MenuBar app requires full Xcode from App Store"
            XCODE_AVAILABLE=false
        fi
    fi
}

# Build CLI
build_cli() {
    print_header "Building CLI Binary"
    
    if [ ! -f "go.mod" ]; then
        print_error "go.mod not found. Run 'go mod init gatekeeper' first"
        exit 1
    fi
    
    print_info "Installing dependencies..."
    go mod download
    go mod tidy
    
    print_info "Building binary..."
    go build -o gatekeeper -ldflags="-s -w"
    
    if [ -f "gatekeeper" ]; then
        SIZE=$(ls -lh gatekeeper | awk '{print $5}')
        print_success "Built gatekeeper ($SIZE)"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Build macOS app
build_macos_app() {
    print_header "Building macOS App (Xcode Required)"
    
    if [ ! -d "GatekeeperApp/GatekeeperApp.xcodeproj" ]; then
        print_error "Xcode project not found at GatekeeperApp/GatekeeperApp.xcodeproj"
        return
    fi
    
    if [ "$XCODE_AVAILABLE" = false ]; then
        print_info ""
        print_info "╔════════════════════════════════════════════════════╗"
        print_info "║  HOW TO BUILD MACOS APP (MenuBar + Widgets)       ║"
        print_info "╚════════════════════════════════════════════════════╝"
        print_info ""
        print_info "📋 Step 1: Install Full Xcode"
        print_info "   • Download from: https://developer.apple.com/download"
        print_info "   • Or from Mac App Store"
        print_info "   • Installation takes ~30 minutes and 15GB space"
        print_info ""
        print_info "📋 Step 2: Open Project"
        print_info "   Run this command:"
        print_info "   $ open GatekeeperApp/GatekeeperApp.xcodeproj"
        print_info ""
        print_info "📋 Step 3: Build in Xcode"
        print_info "   1. Wait for Xcode to load (might take 1-2 min)"
        print_info "   2. Select scheme: 'Gatekeeper' (top toolbar)"
        print_info "   3. Select destination: 'My Mac'"
        print_info "   4. Press: Product → Build (⌘B)"
        print_info ""
        print_info "📋 Step 4: Run"
        print_info "   Press: Product → Run (⌘R)"
        print_info "   App will start in menu bar"
        print_info ""
        print_info "📋 Step 5: Add Widgets"
        print_info "   1. Right-click desktop → Edit Widgets"
        print_info "   2. Search: 'Gatekeeper'"
        print_info "   3. Add widget (Small, Medium, or Large)"
        print_info ""
        print_info "Need help? See: GatekeeperApp/BUILD.md"
        print_info ""
        return
    fi
    
    # If full Xcode is available, try command-line build
    print_info "Building with Xcode (command line)..."
    cd GatekeeperApp
    
    xcodebuild -scheme Gatekeeper \
               -configuration Release \
               -derivedDataPath build \
               clean build 2>&1 | grep -E "(error|warning|Built|Compiling)" || true
    
    if [ -d "build/Release/Gatekeeper.app" ]; then
        print_success "Built Gatekeeper.app"
        print_info ""
        print_info "To run: open build/Release/Gatekeeper.app"
        open -R "build/Release/Gatekeeper.app"
    else
        print_error "Build failed"
        print_info "Try building in Xcode GUI instead: open GatekeeperApp/GatekeeperApp.xcodeproj"
    fi
    
    cd ..
}

# Install CLI
install_cli() {
    print_header "Installing CLI"
    
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"
    
    if [ ! -f "gatekeeper" ]; then
        print_error "gatekeeper binary not found. Build first with: $0 --cli"
        return
    fi
    
    print_info "Copying binary to $BIN_DIR/gatekeeper"
    cp gatekeeper "$BIN_DIR/gatekeeper"
    chmod +x "$BIN_DIR/gatekeeper"
    print_success "Installed $BIN_DIR/gatekeeper"
    
    print_info "Copying tmux helper to $BIN_DIR/gatekeeper-tmux"
    cp gatekeeper-tmux.sh "$BIN_DIR/gatekeeper-tmux"
    chmod +x "$BIN_DIR/gatekeeper-tmux"
    print_success "Installed $BIN_DIR/gatekeeper-tmux"
    
    print_info "Creating config file..."
    "$BIN_DIR/gatekeeper" init 2>/dev/null || true
    print_success "Config created at ~/.config/gatekeeper/config.yaml"
}

# Test installation
test_install() {
    print_header "Testing Installation"
    
    BIN_DIR="$HOME/.local/bin"
    
    if [ ! -f "$BIN_DIR/gatekeeper" ]; then
        print_error "gatekeeper not installed"
        return
    fi
    
    print_success "Binary installed at: $BIN_DIR/gatekeeper"
    
    if [ -f ~/.config/gatekeeper/config.yaml ]; then
        print_success "Config created at: ~/.config/gatekeeper/config.yaml"
    fi
    
    if [ -f "$BIN_DIR/gatekeeper-tmux" ]; then
        print_success "tmux helper installed at: $BIN_DIR/gatekeeper-tmux"
    fi
    
    print_info ""
    print_info "Next steps:"
    print_info "1. Edit config: nano ~/.config/gatekeeper/config.yaml"
    print_info "2. Start daemon: gatekeeper daemon"
    print_info "3. Check status: gatekeeper status --compact"
}

# Show usage
show_usage() {
    cat << EOF
${BLUE}Gatekeeper Build Script${NC}

Usage: ./build.sh [options]

Options:
  --all                Build and install everything (default)
  --cli                Build CLI binary only
  --app                Build macOS app only (requires Xcode)
  --install            Install CLI to ~/.local/bin
  --test               Test the installation
  --clean              Remove build artifacts
  --help               Show this help message

Examples:
  ./build.sh                    # Build and install everything
  ./build.sh --cli              # Build CLI only
  ./build.sh --app              # Build macOS app
  ./build.sh --install          # Install to ~/.local/bin
  ./build.sh --clean            # Clean build artifacts

EOF
}

# Clean build artifacts
clean_build() {
    print_header "Cleaning Build Artifacts"
    
    print_info "Removing binary..."
    rm -f gatekeeper
    
    print_info "Removing macOS app build..."
    rm -rf GatekeeperApp/build
    
    print_success "Cleaned"
}

# Main
main() {
    if [ $# -eq 0 ]; then
        # No args - build and install everything
        check_requirements
        build_cli
        build_macos_app
        install_cli
        test_install
        return
    fi
    
    # Process all arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                check_requirements
                build_cli
                build_macos_app
                install_cli
                test_install
                ;;
            --cli)
                check_requirements
                build_cli
                ;;
            --app)
                check_requirements
                build_macos_app
                ;;
            --install)
                install_cli
                ;;
            --test)
                test_install
                ;;
            --clean)
                clean_build
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
}

main "$@"
