#!/bin/bash
set -e

# Write flag — always exactly this block
mkdir -p /root
echo "${CTF_FLAG}" > /root/flag.txt
chmod 600 /root/flag.txt
chown root:root /root/flag.txt

# === Lab setup ===
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends sudo firefox-esr vim-tiny
rm -rf /var/lib/apt/lists/*

# Ensure the player has no useful sudo rights
printf 'kasm-user ALL=(ALL) !ALL\n' > /etc/sudoers.d/kasm-user-deny
chmod 440 /etc/sudoers.d/kasm-user-deny

# Create a beginner-friendly hint file on the desktop
mkdir -p /home/kasm-user/Desktop
cat > /home/kasm-user/Desktop/README-LAB.txt <<'EOF'
Beginner Privilege Escalation Lab

Goal:
- Become root
- Read /root/flag.txt

Suggested steps:
1. Open a terminal
2. Run: id
3. Run: whoami
4. Run: sudo -l
5. Run: find / -perm -4000 -type f 2>/dev/null
6. Look for an interesting SUID binary that appears in GTFOBins
7. Use the GTFOBins SUID technique to spawn a root shell
8. Confirm with: whoami
9. Read the flag: cat /root/flag.txt

Hint:
- A classic editor binary has been left with the SUID bit set.
EOF
chown -R kasm-user:kasm-user /home/kasm-user/Desktop

# Deliberately vulnerable SUID binary for escalation
chown root:root /usr/bin/vim.tiny
chmod 4755 /usr/bin/vim.tiny
ln -sf /usr/bin/vim.tiny /usr/local/bin/suid-vim
chown root:root /usr/local/bin/suid-vim
chmod 4755 /usr/local/bin/suid-vim

# MOTD shown in the player's terminal
printf 'Secubox Kali Lab: SUID Binary Privilege Escalation\n\nYou are logged in as an unprivileged user.\nCheck your identity and privileges with: id, whoami, sudo -l\nThen enumerate SUID binaries with: find / -perm -4000 -type f 2>/dev/null\nOne of the discovered binaries can be used with a GTFOBins SUID technique to spawn a root shell.\nGoal: become root and read /root/flag.txt\n' > /etc/motd

export KASM_VNC_CMD="bash"
# Kasm startup — must be last line
exec /dockerstartup/vnc_startup.sh