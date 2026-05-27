#!/bin/bash
set -e

# Write flag as root-only readable file
mkdir -p /root
echo "${CTF_FLAG}" > /root/flag.txt
chmod 600 /root/flag.txt
chown root:root /root/flag.txt

# Kasm expects to run as kasm-user — set up the lab environment for them
echo "player:player" | chpasswd 2>/dev/null || true
su -c "echo 'cat /etc/motd' >> /home/kasm-user/.bashrc" kasm-user 2>/dev/null || true

# Start the Kasm VNC session with a terminal as the main app
export KASM_VNC_CMD="bash"

exec /dockerstartup/vnc_startup.sh
