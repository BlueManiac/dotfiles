#!/bin/bash

main() {
	# ===== System update =====

	# Update packages
	echo "Updating packages..."
	sudo paru -Syu --noconfirm

	# ===== Applications =====
	
	# Brave browser
	echo "Installing Brave browser..."
	sudo paru -S --needed --noconfirm brave-bin

	# Etcher
	echo "Installing Etcher..."
	sudo paru -S --needed --noconfirm etcher-bin

	# LM Studio
	echo "Installing LM Studio..."
	paru -S --needed --noconfirm lmstudio-bin

	# .NET
	echo "Installing .NET SDK..."
	sudo paru -S --needed --noconfirm dotnet-sdk

	# Node.js
	echo "Installing Node.js..."
	sudo paru -S --needed --noconfirm nodejs npm

	# Ollama
	echo "Installing Ollama..."
	sudo paru -S --needed --noconfirm ollama

	# OnlyOffice
	echo "Installing OnlyOffice..."
	paru -S --needed --noconfirm onlyoffice-bin

	# Visual Studio Code
	echo "Installing Visual Studio Code..."
	paru -S --needed --noconfirm visual-studio-code-bin

	# ===== CLI tooling =====

	# Codex CLI
	echo "Installing Codex CLI..."
	sudo npm install -g @openai/codex@latest

	# ===== Git and shell configuration =====
	# Git global identity
	echo "Configuring Git global identity..."
	git config --global user.name "BlueManiac"
	git config --global user.email "bluemaniac@users.noreply.github.com"

	# Bash aliases
	echo "Configuring shell aliases..."
	ensure_line_in_file "$HOME/.bashrc" "alias cls='clear'"

	# Data disk auto-mount
	echo "Configuring Data disk auto-mount..."
	if mountpoint -q "/run/media/$USER/Data" 2>/dev/null; then
		local data_device data_uuid data_mount
		data_device=$(findmnt -n -o SOURCE "/run/media/$USER/Data")
		data_uuid=$(sudo blkid -s UUID -o value "$data_device")
		data_mount="/run/media/$USER/Data"
		sudo mkdir -p "$data_mount"
		if ! sudo grep -q "^UUID=$data_uuid" /etc/fstab; then
			echo "UUID=$data_uuid $data_mount ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab > /dev/null
		fi
	fi

	# Projects symlink
	echo "Setting up Projects symlink..."
	ln -sfn "/run/media/$USER/Data/Projects" "$HOME/Projects"

	# ===== Editor and terminal configuration =====
	# VS Code default shell
	echo "Configuring VS Code default shell..."
	ensure_json_key_value \
		"$HOME/.config/Code/User/settings.json" \
		"terminal.integrated.defaultProfile.linux" \
		"bash"

	# Alacritty configuration
	if command -v alacritty &> /dev/null; then
		echo "Configuring Alacritty..."
		ensure_line_in_file \
			"$HOME/.config/alacritty/alacritty.toml" \
			"shell.program = \"/bin/bash\"" \
			"^\s*shell\.program\s*=" \
			"[terminal]"
	fi
	
	# ===== Desktop-specific configuration =====
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

		echo "Setting GNOME text scaling factor..."
		gsettings set org.gnome.desktop.interface text-scaling-factor 1.03

		# Nautilus context menu - Open with Code
		echo "Setting up Nautilus context menu - Open with Code..."
		mkdir -p "$HOME/.local/share/nautilus/scripts"
		cat > "$HOME/.local/share/nautilus/scripts/Open with Code" << 'EOF'
#!/bin/bash
code "$1"
EOF
		chmod +x "$HOME/.local/share/nautilus/scripts/Open with Code"
	fi
}

get_desktop() {
	local raw_current_desktop="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-}}"
	local current_desktop="${raw_current_desktop%%:*}"
	current_desktop="${current_desktop,,}"

	printf '%s\n' "${current_desktop:-unknown}"
}

ensure_line_in_file() {
	# File to edit (creates if missing)
	local file_path="$1"
	# Line content to add/replace
	local line="$2"
	# (optional) regex to match for replacement
	local pattern="${3:-}"
	# (optional) line to insert after (creates if missing)
	local marker="${4:-}"

	mkdir -p "$(dirname "$file_path")"
	touch "$file_path"

	# Replace if pattern matches
	if [ -n "$pattern" ] && grep -qE "$pattern" "$file_path"; then
		sed -i "s|$pattern.*|$line|" "$file_path"
		return
	fi

	# Don't add if line already exists
	if grep -Fqx "$line" "$file_path"; then
		return
	fi

	# Ensure marker exists if specified
	if [ -n "$marker" ] && ! grep -Fqx "$marker" "$file_path"; then
		printf '%s\n' "$marker" >> "$file_path"
	fi

	# Add line after marker or at end
	if [ -n "$marker" ]; then
		sed -i "/$(sed 's/[&/\[\]]/\\&/g' <<< "$marker")/a $line" "$file_path"
	else
		printf '%s\n' "$line" >> "$file_path"
	fi
}

ensure_json_key_value() {
	local file_path="$1"
	local json_key="$2"
	local json_value="$3"

	if ! command -v jq &> /dev/null; then
		echo "jq is required to edit JSON files" >&2
		return 1
	fi

	mkdir -p "$(dirname "$file_path")"
	[ -f "$file_path" ] || echo '{}' > "$file_path"

	local tmp_file
	tmp_file="$(mktemp)"
	jq --arg key "$json_key" --arg value "$json_value" '.[$key] = $value' "$file_path" > "$tmp_file"
	mv "$tmp_file" "$file_path"
}

set -euo pipefail
main "$@"
