#!/bin/bash

main() {
	desktop="$(get_desktop)"

	# Brave browser
	echo "Installing Brave browser..."
	paru -S --noconfirm brave-bin

	# Visual Studio Code
	echo "Installing Visual Studio Code..."
	paru -S --noconfirm visual-studio-code-bin

	# Git global identity
	echo "Configuring Git global identity..."
	git config --global user.name "BlueManiac"
	git config --global user.email "bluemaniac@users.noreply.github.com"

    # Gnome settings
	if [ "$desktop" = "gnome" ]; then
        echo "Installing Vitals GNOME extension..."
        sudo pacman -S --noconfirm libgtop lm_sensors
        paru -S --noconfirm gnome-shell-extension-vitals
        # Restart needed here
        gnome-extensions enable Vitals@CoreCoding.com

        # Keyboard shortcuts
        echo "Setting up GNOME keyboard shortcuts..."
        gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
	fi
}

get_desktop() {
	local raw_current_desktop="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-}}"
	local current_desktop="${raw_current_desktop%%:*}"
	current_desktop="${current_desktop,,}"

	printf '%s\n' "${current_desktop:-unknown}"
}

set -euo pipefail
main "$@"
