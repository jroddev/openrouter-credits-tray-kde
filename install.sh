#!/bin/bash
# Install or upgrade the OpenRouter Credits Monitor plasmoid for KDE Plasma 6.
# Usage:
#   ./install.sh           Install the plasmoid
#   ./install.sh --upgrade Reinstall/update the plasmoid
#   ./install.sh --update  Same as --upgrade

set -e

PLASMOID_ID="com.openrouter.credits-monitor"
PACKAGE_DIR="package"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_PATH="$SCRIPT_DIR/$PACKAGE_DIR"

if [ ! -d "$PACKAGE_PATH" ]; then
    echo "Error: $PACKAGE_DIR directory not found at $PACKAGE_PATH"
    exit 1
fi

if [ "$1" = "--upgrade" ] || [ "$1" = "--update" ]; then
    echo "Upgrading $PLASMOID_ID..."
    if kpackagetool6 --type Plasma/Applet --upgrade "$PACKAGE_PATH" 2>/dev/null; then
        echo "Upgraded via kpackagetool6."
    else
        echo "kpackagetool6 upgrade failed, falling back to manual install..."
        mkdir -p "$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"
        cp -r "$PACKAGE_PATH"/* "$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID/"
        echo "Installed via manual copy."
    fi
else
    echo "Installing $PLASMOID_ID..."
    if kpackagetool6 --type Plasma/Applet --install "$PACKAGE_PATH" 2>/dev/null; then
        echo "Installed via kpackagetool6."
    else
        echo "kpackagetool6 install failed, falling back to manual install..."
        mkdir -p "$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"
        cp -r "$PACKAGE_PATH"/* "$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID/"
        echo "Installed via manual copy."
    fi
fi

echo "Done."

read -rp "Restart plasmashell now? [Y/n] " answer
if [[ -z "$answer" || "$answer" =~ ^[Yy] ]]; then
    echo "Restarting plasmashell..."
    killall plasmashell
    echo "Plasmashell restarted."
else
    echo "Skipped restart. You may need to restart plasmashell manually for changes to take effect."
fi
