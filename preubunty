#!/bin/bash

set -e

echo "[*] Updating base system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing essential development tools..."
sudo apt install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    python3 \
    python3-pip \
    python3-dev \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    libz-dev \
    ruby \
    ruby-dev \
    gnupg2 \
    jq \
    sshpass \
    lsb-release

########################################
# Add Wazuh APT Repository
########################################
echo "[*] Adding Wazuh APT repository and GPG key..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/wazuh.gpg
echo "deb https://packages.wazuh.com/4.x/apt stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list

sudo apt update

########################################
# Node.js (for Wazuh dashboard development)
########################################
echo "[*] Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

echo "[*] Installing Yarn (optional, used in dashboard)"
npm install -g yarn

########################################
# Docker (for containerized environments and vagrant alt.)
########################################
echo "[*] Installing Docker and Docker Compose..."
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER

########################################
# Optional: Add Elastic Stack 7.x Repository (if used with Wazuh)
########################################
echo "[*] Adding Elastic 7.x repository..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/elastic.gpg
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

sudo apt update

########################################
# Install Go (required for Wazuh API backend & utils)
########################################
echo "[*] Installing Go 1.22.x..."
GO_VERSION="1.22.3"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

if ! grep -q '/usr/local/go/bin' ~/.profile; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi

source ~/.profile
go version

########################################
# Optional: Python dependencies for Wazuh API
########################################
echo "[*] Installing Python dependencies..."
pip3 install uvicorn fastapi requests cryptography

########################################
# Clean and Summary
########################################
echo "[*] Wazuh dev environment for Ubuntu 24.04 is set up."
echo "[!] Reboot or log out/in for Docker group changes to apply."
