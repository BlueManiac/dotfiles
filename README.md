# dotfiles

## Install Script

The `install.sh` script installs all applications on CachyOS.

### Usage

```bash
chmod +x install.sh
./install.sh
```

### What gets installed

- **Vitals GNOME extension** – system monitor for the GNOME top bar (CPU, memory, temperature, network, and more)
  - `libgtop`, `lm_sensors` via pacman
  - `gnome-shell-extension-vitals` via paru (AUR)
  - Runs `sensors-detect` interactively to configure hardware sensor detection
- **Brave** – privacy-focused web browser (`brave-bin` via paru)
  - Not in the official Arch repos, so paru (AUR) is used instead of pacman
  - Flatpak is available but paru gives a native package with better system integration
- **Visual Studio Code** – code editor (`visual-studio-code-bin` via paru)
  - The full Microsoft binary (with proprietary extension marketplace) is not in the official Arch repos; only the open-source `code` build is — so paru (AUR) is used
  - Flatpak is available but has sandbox restrictions that affect terminal integration and some extensions