#!/bin/bash
# Gatekeeper Build Script - CLI only

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

# Install CLI
install_cli() {
    print_header "Installing CLI"

    if [ ! -f "gatekeeper" ]; then
        print_error "Binary not found. Run './build.sh' first"
        exit 1
    fi

    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"

    cp gatekeeper "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/gatekeeper"

    print_success "Installed to $INSTALL_DIR/gatekeeper"

    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        print_info ""
        print_info "⚠️  Add to your shell config (~/.zshrc or ~/.bashrc):"
        print_info "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Test installation
test_installation() {
    print_header "Testing Installation"

    if command -v gatekeeper &> /dev/null; then
        print_success "gatekeeper is in PATH"
        gatekeeper --help > /dev/null 2>&1 && print_success "Command executes successfully"
    else
        print_error "gatekeeper not found in PATH"
        print_info "Make sure ~/.local/bin is in your PATH"
    fi
}

# Clean build artifacts
clean() {
    print_header "Cleaning Build Artifacts"

    rm -f gatekeeper
    print_success "Cleaned gatekeeper binary"
}

# Show help
show_help() {
    cat << EOF
Gatekeeper Build Script

Usage:
  ./build.sh [options]

Options:
  (no options)          Build CLI binary
  --install            Build and install CLI to ~/.local/bin
  --test               Test if gatekeeper is properly installed
  --clean              Remove build artifacts
  --help               Show this help message

Examples:
  ./build.sh                 # Build CLI
  ./build.sh --install       # Build and install
  ./build.sh --clean         # Clean artifacts

EOF
}

# Parse arguments
INSTALL=false
TEST=false
CLEAN=false

if [ $# -eq 0 ]; then
    # No arguments - build CLI only
    check_requirements
    build_cli
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            INSTALL=true
            shift
            ;;
        --test)
            TEST=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        --cli)
            # Legacy support - ignore
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute based on flags
if [ "$CLEAN" = true ]; then
    clean
    exit 0
fi

if [ "$TEST" = true ]; then
    test_installation
    exit 0
fi

# Build and optionally install
check_requirements
build_cli

if [ "$INSTALL" = true ]; then
    install_cli
    test_installation
fi

print_header "Summary"
if [ "$INSTALL" = true ]; then
    print_success "Build and installation complete!"
    print_info "Run 'gatekeeper init' to get started"
else
    print_success "Build complete!"
    print_info "Run './build.sh --install' to install"
fi
