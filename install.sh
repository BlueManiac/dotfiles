#!/bin/bash

set -euo pipefail

# Install script for CachyOS applications

# Vitals GNOME extension
echo "Installing Vitals GNOME extension..."
sudo pacman -S --noconfirm libgtop lm_sensors
paru -S --noconfirm gnome-shell-extension-vitals
gnome-extensions enable Vitals@CoreCoding.com
sudo sensors-detect
