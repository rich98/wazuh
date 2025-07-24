#!/bin/bash

# Script to remove unwanted GNOME applications from RHEL 9

APPS_TO_REMOVE=(
  gnome-tour      # GNOME Welcome Tour
  eog             # Eye of GNOME (Image Viewer)
  totem           # GNOME Videos / Movie Player
  evolution       # GNOME Email and Calendar
  cheese          # GNOME Webcam Utility
  firefox         # Firefox Web Browser
)

echo "🔧 Starting cleanup of unwanted GNOME applications..."

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo or as root."
  exit 1
fi

# Remove each application if it is installed
for pkg in "${APPS_TO_REMOVE[@]}"; do
  if rpm -q "$pkg" &> /dev/null; then
    echo "➡️  Removing $pkg..."
    dnf remove -y "$pkg"
    echo "✅ $pkg removed."
  else
    echo "ℹ️  $pkg is not installed."
  fi
done

# Optional cleanup of orphaned packages
echo "🧹 Running autoremove for orphaned dependencies..."
dnf autoremove -y

echo "🎉 All specified applications have been processed."

