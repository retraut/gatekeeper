#!/bin/bash
# Gatekeeper tmux status display script
# Usage in .tmux.conf:
#   set -g status-right "#(~/path/to/gatekeeper-tmux.sh)"

GATEKEEPER_BIN="${GATEKEEPER_BIN:-$HOME/.local/bin/gatekeeper}"

if [ ! -x "$GATEKEEPER_BIN" ]; then
    echo "[gatekeeper:offline]"
    exit 0
fi

# Get status and format for tmux
STATUS=$($GATEKEEPER_BIN status --compact 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$STATUS" ]; then
    echo "#[fg=green]🔐 $STATUS#[default]"
else
    echo "#[fg=red]🔐 offline#[default]"
fi
