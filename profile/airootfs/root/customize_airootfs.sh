#!/bin/bash
set -e -u

# Enable services
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable bluetooth.service
systemctl enable ps4-console.service
systemctl enable cpu-performance.service
systemctl set-default multi-user.target

# Create the ps4 user with sudo access
useradd -m -G audio,video,input,render,seat,wheel -s /bin/bash ps4
echo "ps4:ps4" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable user-level PipeWire services as the ps4 user
sudo -u ps4 XDG_RUNTIME_DIR=/run/user/1000 systemctl --user enable pipewire pipewire-pulse wireplumber || true

# Ensure shadPS4 install directory exists and set permissions
mkdir -p /home/ps4/.local/share/shadPS4
chown -R ps4:ps4 /home/ps4
mkdir -p /var/log/shadps4
chown -R ps4:ps4 /var/log/shadps4

# Auto-link the GAMES drive to the emulator's default folder
# So you don't have to fight the unwriteable UI path!
mkdir -p /mnt/games
ln -sfn /mnt/games /home/ps4/games
chown -h ps4:ps4 /home/ps4/games

# Extract shadPS4 from the tarball
if [ -f /var/localrepo/shadps4-custom.tar.gz ]; then
    echo "Installing shadPS4 from tarball..."
    tar -xzf /var/localrepo/shadps4-custom.tar.gz -C /
    chmod +x /usr/bin/shadps4
    echo "shadPS4 installed successfully."
fi

# Force executable permissions and fix line endings
sed -i 's/\r$//' /usr/local/bin/ps4-launch
chmod +x /usr/local/bin/ps4-launch

echo "shadPS4 Console customization complete."
