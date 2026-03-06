#!/usr/bin/env bash

# This script installs Quickshell Lockscreen support for SDDM themes.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.local/share/quickshell-lockscreen"

# 1. Ask for installation
echo -e "\033[1;36m=== Quickshell Lockscreen Installer ===\033[0m"
echo "This will install the Quickshell lockscreen wrapper to $TARGET_DIR."
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# 2. Copy the quickshell-lockscreen directory
echo "Copying lockscreen base files to $TARGET_DIR..."
rm -rf "$TARGET_DIR"
cp -r "$DIR/quickshell-lockscreen" "$TARGET_DIR"

# 3. Create themes_link
echo "Creating themes_link to your local themes folder..."
ln -sfn "$DIR/themes" "$TARGET_DIR/themes_link"

# 4. Make lock.sh executable
chmod +x "$TARGET_DIR/lock.sh"

# 5. Provide theme selection
echo
echo "Available themes:"
ls -1 "$DIR/themes" | sed 's/^/  - /'
echo
read -p "Which theme would you like to set as default? (e.g. Genshin): " THEME_NAME

if [ -z "$THEME_NAME" ] || [ ! -d "$DIR/themes/$THEME_NAME" ]; then
    echo "Theme not found or not specified. Defaulting to 'Genshin'."
    THEME_NAME="Genshin"
fi

sed -i "s/export QS_THEME=.*$/export QS_THEME=\"\${1:-$THEME_NAME}\"/" "$TARGET_DIR/lock.sh"

echo
echo -e "\033[1;32mInstallation complete!\033[0m"
echo -e "You can now lock the screen by running:"
echo -e "  \033[1;33m$TARGET_DIR/lock.sh\033[0m"
echo
echo -e "\033[1;36m=== Lock Screen Keyboard Shortcuts Instructions ===\033[0m"
echo -e "To use this lockscreen natively, bind it to a keyboard shortcut (e.g., Mod + L) in your Window Manager.\n"
echo -e "Here are snippets for common environments:\n"

echo -e "\033[1;34m[ Qtile ] (in ~/.config/qtile/config.py)\033[0m"
echo -e "Key([mod], \"l\", lazy.spawn(\"$TARGET_DIR/lock.sh\")),"
echo

echo -e "\033[1;34m[ Hyprland ] (in ~/.config/hypr/hyprland.conf)\033[0m"
echo -e "bind = \$mainMod, L, exec, $TARGET_DIR/lock.sh"
echo

echo -e "\033[1;34m[ Sway ] (in ~/.config/sway/config)\033[0m"
echo -e "bindsym \$mod+l exec $TARGET_DIR/lock.sh"
echo

echo -e "\033[1;34m[ i3 / bspwm / AwesomeWM ]\033[0m"
echo -e "Map your designated lock key to execute \`$TARGET_DIR/lock.sh\` in your respective config file."
echo
