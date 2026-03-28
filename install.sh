#!/bin/bash

main() {
	# ===== System update =====

	echo "Updating packages..."
	sudo paru -Syu --noconfirm

	# ===== Applications =====
	
	echo "Installing Brave browser..."
	sudo paru -S --needed --noconfirm brave-bin

	echo "Installing .NET SDK..."
	sudo paru -S --needed --noconfirm dotnet-sdk

	echo "Installing CachyOS gaming meta package..."
	sudo paru -S --needed --noconfirm cachyos-gaming-meta

	echo "Installing Etcher..."
	sudo paru -S --needed --noconfirm etcher-bin

	echo "Installing LM Studio..."
	paru -S --needed --noconfirm lmstudio-bin

	echo "Installing Node.js..."
	sudo paru -S --needed --noconfirm nodejs npm

	echo "Installing Ollama..."
	sudo paru -S --needed --noconfirm ollama
	sudo systemctl enable --now ollama

	echo "Installing OnlyOffice..."
	paru -S --needed --noconfirm onlyoffice-bin

	echo "Installing Steam..."
	sudo paru -S --needed --noconfirm steam

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

	# Disable bracketed paste (prevents ^[[200~ artifacts when pasting)
	echo "Disabling bracketed paste..."
	ensure_line_in_file "$HOME/.inputrc" "set enable-bracketed-paste off"
	bind -f ~/.inputrc

	# Data disk auto-mount
	configure_disk_mount "Data" "/mnt/Data"
	configure_disk_mount "Files" "/mnt/Files"

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
		echo "Installing GNOME extensions..."
		sudo pacman -S --needed --noconfirm libgtop lm_sensors
		paru -S --needed --noconfirm gnome-shell-extension-vitals gnome-shell-extension-forge
		local extensions=("Vitals@CoreCoding.com" "forge@jmmaranan.com")
		local enabled="$(gsettings get org.gnome.shell enabled-extensions)"
		for ext in "${extensions[@]}"; do
			if [[ "$enabled" != *"$ext"* ]]; then
				echo "Enabling $ext..."
				if [[ "$enabled" == "@as []" ]]; then
					enabled="['$ext']"
				else
					enabled="${enabled/%]/, \'$ext\']}"
				fi
			fi
		done
		gsettings set org.gnome.shell enabled-extensions "$enabled"

		echo "Setting up GNOME keyboard shortcuts..."

		# Move windows between monitors (clears conflicting tiling defaults)
		gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Super>Left']"
		gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Super>Right']"
		gsettings set org.gnome.mutter.keybindings toggle-tiled-left "[]"
		gsettings set org.gnome.mutter.keybindings toggle-tiled-right "[]"

		# Close window (clears conflicting Forge focus-border-toggle)
		gsettings set org.gnome.desktop.wm.keybindings close "['<Super>x']"
		gsettings set org.gnome.shell.extensions.forge.keybindings focus-border-toggle "[]"
		gsettings set org.gnome.shell.extensions.forge.keybindings window-toggle-float "[]"

		# Other shortcuts
		gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
		gsettings set org.gnome.shell.keybindings show-screenshot-ui "['Print', '<Shift><Super>s']"

		# Focus follows mouse (hover to focus, keeps focus over empty space)
		gsettings set org.gnome.desktop.wm.preferences focus-mode 'sloppy'
		gsettings set org.gnome.mutter focus-change-on-pointer-rest false

		# Clear conflicts with <Super>w
		gsettings set org.gnome.shell.extensions.forge.keybindings prefs-tiling-toggle "[]"

		echo "Setting up GNOME custom keybindings..."
		local kb_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
		local kb_schema="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
		local custom_bindings=(
			"Alacritty|alacritty|<Super>q"
			"File Manager|nautilus|<Super>e"
			"VS Code|code|<Super>c"
			"Brave|brave|<Super>w"
		)

		local kb_list=$(printf "'$kb_path/custom%s/', " "${!custom_bindings[@]}")
		gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[${kb_list%, }]"

		for i in "${!custom_bindings[@]}"; do
			IFS='|' read -r name command binding <<< "${custom_bindings[$i]}"
			gsettings set "$kb_schema:$kb_path/custom$i/" name "$name"
			gsettings set "$kb_schema:$kb_path/custom$i/" command "$command"
			gsettings set "$kb_schema:$kb_path/custom$i/" binding "$binding"
		done

		echo "Setting up GNOME workspace shortcuts..."
		for workspace in {1..9}; do
			gsettings set org.gnome.shell.keybindings "switch-to-application-$workspace" "[]"
			gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$workspace" "['<Super>$workspace']"
			gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-$workspace" "['<Super><Shift>$workspace']"
		done
		
		echo "Configuring GNOME workspaces..."
		gsettings set org.gnome.mutter dynamic-workspaces false
		gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

		echo "Setting GNOME text scaling factor..."
		gsettings set org.gnome.desktop.interface text-scaling-factor 1.03

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

configure_disk_mount() {
	local disk_label="$1"
	local mount_point="$2"
	local disk_device

	echo "Configuring $disk_label disk auto-mount..."
	disk_device="$(findfs "LABEL=$disk_label" 2>/dev/null || true)"
	if [ -z "$disk_device" ]; then
		echo "Skipping $disk_label disk fstab entry: could not find disk labeled $disk_label." >&2
		return
	fi

	local disk_uuid="$(sudo blkid -s UUID -o value "$disk_device")"
	local disk_fs_type="$(sudo blkid -s TYPE -o value "$disk_device")"
	if [ -z "$disk_uuid" ] || [ -z "$disk_fs_type" ]; then
		echo "Skipping $disk_label disk fstab entry: could not detect UUID or filesystem type." >&2
		return
	fi

	local fstab_fs_type="$disk_fs_type"
	local mount_options="defaults,nofail,x-gvfs-show,x-gvfs-name=$disk_label"
	local passno="0"

	case "$disk_fs_type" in
		ntfs|ntfs3|ntfs-3g)
			fstab_fs_type="ntfs3"
			mount_options="uid=$(id -u),gid=$(id -g),umask=022,nofail,x-gvfs-show,x-gvfs-name=$disk_label"
			;;
		ext2|ext3|ext4)
			passno="2"
			;;
	esac

	sudo mkdir -p "$mount_point"
	ensure_fstab_mount "$disk_uuid" "$mount_point" "$fstab_fs_type" "$mount_options" "$passno"
	if ! mountpoint -q "$mount_point" 2>/dev/null; then
		sudo mount "$mount_point" 2>/dev/null || true
	fi
}

ensure_fstab_mount() {
	local uuid="$1"
	local mount_point="$2"
	local fs_type="$3"
	local mount_options="$4"
	local passno="$5"
	local entry="UUID=$uuid $mount_point $fs_type $mount_options 0 $passno"
	local tmp_file

	tmp_file="$(mktemp)"
	if awk -v uuid="$uuid" -v entry="$entry" '
		BEGIN { updated = 0 }
		$1 == "UUID=" uuid { print entry; updated = 1; next }
		{ print }
		END { if (!updated) print entry }
	' /etc/fstab > "$tmp_file"; then
		sudo mv "$tmp_file" /etc/fstab
	else
		rm -f "$tmp_file"
		return 1
	fi
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
