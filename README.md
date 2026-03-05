# dotfiles

## Install Script

The `install.sh` script can be used to install applications on CachyOS.

### Usage

```bash
chmod +x install.sh
./install.sh [options]
```

### Options

| Option | Description |
|--------|-------------|
| `--vitals` | Install the [Vitals GNOME extension](https://github.com/corecoding/Vitals) (system monitor for the GNOME top bar) |
| `--all` | Install all applications |
| `-h`, `--help` | Show help message |

### Examples

Install the Vitals GNOME extension:

```bash
./install.sh --vitals
```

Install all applications:

```bash
./install.sh --all
```

### What gets installed

#### Vitals GNOME Extension (`--vitals`)

Installs a system monitor extension for the GNOME top bar that shows CPU, memory, temperature, network, and more.

- `libgtop` – system resource monitoring library
- `lm_sensors` – hardware sensor reading tools
- `gnome-shell-extension-vitals` – the GNOME Shell extension (from AUR via `paru`)

After installation, `sensors-detect` is run interactively to configure hardware sensor detection.