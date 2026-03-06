#!/bin/bash

set -euo pipefail

# Install script for CachyOS applications

# Vitals GNOME extension
echo "Installing Vitals GNOME extension..."
sudo pacman -S --noconfirm libgtop lm_sensors
paru -S --noconfirm gnome-shell-extension-vitals
# Restart needed here
gnome-extensions enable Vitals@CoreCoding.com

# Brave browser
echo "Installing Brave browser..."
paru -S --noconfirm brave-bin

# Visual Studio Code
echo "Installing Visual Studio Code..."
paru -S --noconfirm visual-studio-code-bin
