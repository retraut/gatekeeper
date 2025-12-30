#!/bin/bash
# Installation script for Gatekeeper

set -e

echo "🔐 Building Gatekeeper..."
go build -o gatekeeper

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

echo "📦 Installing binary to $BIN_DIR/gatekeeper"
cp gatekeeper "$BIN_DIR/gatekeeper"
chmod +x "$BIN_DIR/gatekeeper"

echo "📝 Installing tmux helper to $BIN_DIR/gatekeeper-tmux"
cp gatekeeper-tmux.sh "$BIN_DIR/gatekeeper-tmux"
chmod +x "$BIN_DIR/gatekeeper-tmux"

echo "⚙️  Initializing config"
"$BIN_DIR/gatekeeper" init

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Add to .tmux.conf:"
echo '   set -g status-right "#(~/.local/bin/gatekeeper-tmux)"'
echo ""
echo "2. Start daemon:"
echo "   gatekeeper daemon"
echo ""
echo "3. Check status:"
echo "   gatekeeper status"
