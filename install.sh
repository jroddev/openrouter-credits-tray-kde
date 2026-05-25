#!/bin/bash
# Install or upgrade the OpenRouter Credits Monitor plasmoid for KDE Plasma 6.
# Usage:
#   ./install.sh           Install the plasmoid
#   ./install.sh --upgrade Reinstall/update the plasmoid

set -e

PLASMOID_ID="com.openrouter.credits-monitor"
PACKAGE_DIR="package"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_PATH="$SCRIPT_DIR/$PACKAGE_DIR"

if [ ! -d "$PACKAGE_PATH" ]; then
    echo "Error: $PACKAGE_DIR directory not found at $PACKAGE_PATH"
    exit 1
fi

if [ "$1" = "--upgrade" ]; then
    echo "Upgrading $PLASMOID_ID..."
    kpackagetool6 --type Plasma/Plasmoid --upgrade "$PACKAGE_PATH"
else
    echo "Installing $PLASMOID_ID..."
    kpackagetool6 --type Plasma/Plasmoid --install "$PACKAGE_PATH"
fi

echo "Done."

read -rp "Restart plasmashell now? [Y/n] " answer
if [[ -z "$answer" || "$answer" =~ ^[Yy] ]]; then
    echo "Restarting plasmashell..."
    systemctl --user restart plasma-plasmashell
    echo "Plasmashell restarted."
else
    echo "Skipped restart. You may need to restart plasmashell manually for changes to take effect."
fi
