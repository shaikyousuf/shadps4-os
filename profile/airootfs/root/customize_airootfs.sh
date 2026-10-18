#!/bin/bash
set -e -u

# Enable services
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable ps4-console.service
systemctl enable cpu-performance.service
systemctl set-default multi-user.target
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service
systemctl enable bluetooth.service

# Create the ps4 user
useradd -m -G audio,video,input,render,seat -s /bin/bash ps4
echo "ps4:ps4" | chpasswd

# Enable user-level PipeWire services as the ps4 user
sudo -u ps4 XDG_RUNTIME_DIR=/run/user/1000 systemctl --user enable pipewire pipewire-pulse wireplumber || true

# Ensure shadPS4 install directory exists
mkdir -p /home/ps4/.local/share/shadPS4
chown -R ps4:ps4 /home/ps4/.local

# Extract shadPS4 from the tarball placed by GitHub Actions
if [ -f /var/localrepo/shadps4-custom.tar.gz ]; then
    echo "Installing shadPS4 from tarball..."
    tar -xzf /var/localrepo/shadps4-custom.tar.gz -C /
    chmod +x /usr/bin/shadps4
    echo "shadPS4 installed successfully."
fi

# Give ps4 user sudo access and fix log directory permissions
usermod -aG wheel ps4
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
mkdir -p /var/log/shadps4
chown -R ps4:ps4 /var/log/shadps4

echo "shadPS4 Console customization complete."
