#!/bin/bash

# Description: Configures firewalld to allow Nessus (TCP 8834)
# Author: Security Administrator
# Date: July 2025

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root"
  exit 1
fi

echo "📦 Checking if firewalld is active..."
systemctl is-active --quiet firewalld
if [ $? -ne 0 ]; then
  echo "🚀 Starting firewalld..."
  systemctl start firewalld
  systemctl enable firewalld
fi

echo "🔧 Adding firewall rule for Nessus (TCP 8834)..."
firewall-cmd --permanent --add-port=8834/tcp

echo "🔄 Reloading firewall to apply changes..."
firewall-cmd --reload

echo "✅ Firewall rule added: TCP port 8834 is now open."
firewall-cmd --list-ports | grep 8834

