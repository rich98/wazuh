#!/bin/bash
# Wazuh SIEM All-in-One Setup and Hardening Script for RHEL 9.6
# Author: [Your Name]
# Date: $(date +%Y-%m-%d)
# Description: This script installs Wazuh and hardens the host system

set -e

### --- SYSTEM PREPARATION --- ###
echo "[+] Updating system and installing prerequisites..."
sudo dnf update -y
sudo dnf install -y curl wget unzip tar net-tools firewalld \
    policycoreutils-python-utils vim lsof epel-release chrony audit aide

sudo systemctl enable --now chronyd

### --- ENABLE REPOS --- ###
echo "[+] Enabling required repositories..."
sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms || true

### --- FIREWALL CONFIGURATION --- ###
echo "[+] Configuring firewalld for Wazuh..."
sudo systemctl enable --now firewalld
for port in 1514 1515 55000 9200 443; do
    sudo firewall-cmd --permanent --add-port=${port}/tcp
done
sudo firewall-cmd --reload

### --- WAZUH INSTALLATION --- ###
echo "[+] Downloading and installing Wazuh..."
curl -sO https://packages.wazuh.com/4.8/wazuh-install.sh
chmod +x wazuh-install.sh
sudo ./wazuh-install.sh -a

### --- SSH HARDENING --- ###
echo "[+] Hardening SSH configuration..."
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?Protocol.*/Protocol 2/' /etc/ssh/sshd_config
echo "Ciphers aes256-ctr,aes192-ctr,aes128-ctr" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd

### --- AUDITD SETUP --- ###
echo "[+] Configuring auditd..."
sudo systemctl enable --now auditd
sudo tee /etc/audit/rules.d/harden.rules > /dev/null <<EOF
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/group -p wa -k group_changes
-w /etc/sudoers -p wa -k sudoers_changes
EOF
sudo augenrules --load
sudo systemctl restart auditd

### --- AIDE SETUP --- ###
echo "[+] Initializing AIDE..."
sudo aide --init
sudo cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
echo "0 5 * * * root /usr/sbin/aide --check" | sudo tee -a /etc/crontab

### --- FILE LIMITS FOR WAZUH --- ###
echo "[+] Setting file limits for Wazuh..."
echo "wazuh hard nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "wazuh soft nofile 65536" | sudo tee -a /etc/security/limits.conf

### --- SELINUX CONFIGURATION --- ###
echo "[+] Setting SELinux to permissive mode..."
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

### --- DNF AUTOMATIC UPDATES --- ###
echo "[+] Enabling automatic security updates..."
sudo dnf install -y dnf-automatic
sudo systemctl enable --now dnf-automatic.timer

### --- PASSWORD POLICY --- ###
echo "[+] Enforcing strong password policies..."
sudo dnf install -y libpwquality
sudo tee /etc/security/pwquality.conf > /dev/null <<EOF
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
EOF
sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

### --- LOG ROTATION --- ###
echo "[+] Setting up Wazuh log rotation..."
sudo tee /etc/logrotate.d/wazuh > /dev/null <<EOF
/var/ossec/logs/*.log {
    weekly
    rotate 8
    compress
    missingok
    notifempty
    create 640 root adm
}
EOF

### --- SERVICE DISABLING --- ###
echo "[+] Disabling unnecessary services..."
for svc in cups bluetooth; do
    sudo systemctl disable --now $svc || true
done

### --- DONE --- ###
echo "[✓] Wazuh installation and hardening complete. Access the dashboard at: https://<your-ip>/"
echo "Use the password stored in ~/wazuh-install-files/wazuh-passwords.txt to log in."

