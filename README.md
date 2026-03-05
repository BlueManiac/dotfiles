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
- **Visual Studio Code** – code editor (`visual-studio-code-bin` via paru)