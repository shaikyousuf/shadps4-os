#!/bin/bash
set -e -u

# Enable services
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable ps4-console.service
systemctl enable cpu-performance.service
systemctl set-default multi-user.target

# Create the ps4 user
useradd -m -G audio,video,input,render,seat -s /bin/bash ps4
echo "ps4:ps4" | chpasswd

# Enable user-level PipeWire services as the ps4 user
sudo -u ps4 XDG_RUNTIME_DIR=/run/user/1000 systemctl --user enable pipewire pipewire-pulse wireplumber || true

# Ensure shadPS4 install directory exists
mkdir -p /home/ps4/.local/share/shadPS4
chown -R ps4:ps4 /home/ps4/.local

echo "shadPS4 Console customization complete."