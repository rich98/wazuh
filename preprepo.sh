#!/bin/bash

set -e

echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing required tools for offline APT repositories..."
sudo apt install -y \
    apt-mirror \
    dpkg-dev \
    gnupg \
    apache2 \
    rsync \
    tree \
    createrepo-c \
    apt-utils

########################################
# Setup directory structure
########################################
echo "[*] Creating offline repo directory..."
REPO_BASE="/opt/offline-repo"
sudo mkdir -p ${REPO_BASE}/{conf,mirror,packages,pool,dists}

echo "[*] Setting permissions..."
sudo chown -R $USER:$USER ${REPO_BASE}

########################################
# Optional: GPG Key for Signing
########################################
echo "[*] Generating GPG key for repo signing (optional)..."
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Offline Repo Signing
Name-Email: offline@example.local
Expire-Date: 2y
%commit
EOF

echo "[*] Exporting GPG key..."
gpg --armor --export > ${REPO_BASE}/repo-signing-key.pub
gpg --export-secret-keys > ${REPO_BASE}/repo-signing-key.sec

########################################
# Apache setup to optionally host repo locally
########################################
echo "[*] Configuring Apache to serve offline repo..."
sudo ln -s ${REPO_BASE} /var/www/html/offline-repo
sudo systemctl enable apache2
sudo systemctl restart apache2

########################################
# Add helpful README to repo root
########################################
cat > ${REPO_BASE}/README.txt <<EOF
This is a local offline APT repository. To use it:

1. Import the GPG key (if enabled):
   sudo apt-key add repo-signing-key.pub

2. Add to your APT sources:
   echo "deb [trusted=yes] file:/opt/offline-repo ./" | sudo tee /etc/apt/sources.list.d/offline.list

3. Run:
   sudo apt update
EOF

########################################
# Summary
########################################
echo "[*] Offline repo environment prepared at ${REPO_BASE}"
echo "[*] Use apt-mirror or apt download to collect packages."
echo "[!] You must manually populate /opt/offline-repo/pool and run 'dpkg-scanpackages'."

