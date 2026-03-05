#!/bin/bash

set -euo pipefail

# Install script for CachyOS applications

check_paru() {
    if ! command -v paru &>/dev/null; then
        echo "Error: 'paru' AUR helper is not installed. Please install it first: https://github.com/Morganamilo/paru"
        exit 1
    fi
}

install_vitals() {
    echo "Installing Vitals GNOME extension..."

    check_paru

    # Install dependencies
    if ! sudo pacman -S --noconfirm libgtop lm_sensors; then
        echo "Error: Failed to install dependencies via pacman."
        exit 1
    fi

    # Install the extension via AUR
    if ! paru -S --noconfirm gnome-shell-extension-vitals; then
        echo "Error: Failed to install gnome-shell-extension-vitals via paru."
        exit 1
    fi

    # Enable the extension
    gnome-extensions enable Vitals@CoreCoding.com

    # Detect sensors interactively (prompts user for hardware sensor configuration)
    echo "Running sensors-detect to configure hardware sensor detection (interactive)..."
    sudo sensors-detect

    echo "Vitals GNOME extension installed and enabled."
}

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --vitals    Install the Vitals GNOME extension"
    echo "  --all       Install all applications"
    echo "  -h, --help  Show this help message"
}

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

for arg in "$@"; do
    case $arg in
        --vitals)
            install_vitals
            ;;
        --all)
            install_vitals
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            usage
            exit 1
            ;;
    esac
done
