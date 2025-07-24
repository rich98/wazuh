#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root or using sudo."
    exit 1
fi

# Define the banner message
BANNER_TEXT='Use of Thales systems, services and networks is strictly limited to Thales employees and authorised users. All users are subject to the directives found in the "Thales UK Acceptable Usage Policy", which strictly forbids, the accessing and/or downloading of pornographic, offensive, abusive, racist or any material contravening UK legislative Acts. In addition, the downloading and/or installation of unauthorised software and the sharing, disclosure or use of passwords belonging to yourself or others without formal business approval, is strictly forbidden. Any Thales employee, or authorised user, engaging in such activities will be subject to disciplinary proceedings which may result in dismissal.'

# Apply banner to /etc/motd (Message of the Day)
echo "$BANNER_TEXT" > /etc/motd
chmod 644 /etc/motd

# Apply GNOME login banner using dconf system profile
DCONF_DIR="/etc/dconf/db/local.d"
LOCKS_DIR="/etc/dconf/db/local.d/locks"

mkdir -p "$DCONF_DIR"
mkdir -p "$LOCKS_DIR"

# Write the GNOME login banner settings
cat > "$DCONF_DIR/00-login-banner" <<EOF
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='$BANNER_TEXT'
EOF

# Lock the GNOME settings to prevent override
echo "/org/gnome/login-screen/banner-message-enable" > "$LOCKS_DIR/login-banner"
echo "/org/gnome/login-screen/banner-message-text" >> "$LOCKS_DIR/login-banner"

# Update dconf database
dconf update

echo "✅ Login banner has been successfully set for both GNOME and /etc/motd."


