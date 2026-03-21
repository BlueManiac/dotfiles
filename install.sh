#!/bin/bash

main() {
	# Update packages
	echo "Updating packages..."
	sudo paru -Syu --noconfirm

	# Brave browser
	echo "Installing Brave browser..."
	sudo paru -S --needed --noconfirm brave-bin

	# Visual Studio Code
	echo "Installing Visual Studio Code..."
	sudo paru -S --needed --noconfirm visual-studio-code-bin

	# .NET
	echo "Installing .NET SDK..."
	sudo paru -S --needed --noconfirm dotnet-sdk

	# Node.js
	echo "Installing Node.js..."
	sudo paru -S --needed --noconfirm nodejs npm

	# Git global identity
	echo "Configuring Git global identity..."
	git config --global user.name "BlueManiac"
	git config --global user.email "bluemaniac@users.noreply.github.com"

	# Bash aliases
	echo "Configuring shell aliases..."
	ensure_line_in_file "$HOME/.bashrc" "alias cls='clear'"
	
	desktop="$(get_desktop)"

	# GNOME settings
	if [ "$desktop" = "gnome" ]; then
		echo "Installing Vitals GNOME extension..."
		sudo pacman -S --needed --noconfirm libgtop lm_sensors
		sudo paru -S --needed --noconfirm gnome-shell-extension-vitals
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

ensure_line_in_file() {
	local file_path="$1"
	local line="$2"

	touch "$file_path"

	if ! grep -Fqx "$line" "$file_path"; then
		printf '%s\n' "$line" >> "$file_path"
	fi
}

set -euo pipefail
main "$@"
