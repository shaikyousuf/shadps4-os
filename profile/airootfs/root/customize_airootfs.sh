#!/bin/bash
set -e -u

# Enable required services
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable bluetooth.service
systemctl enable seatd.service
systemctl mask archinstall.service || true

# MASK archinstall to prevent the blue screen fallback
systemctl mask archinstall.service || true
systemctl mask systemd-firstboot.service || true

# Create the ps4 user
useradd -m -G audio,video,input,render,seat,wheel -s /bin/bash ps4
echo "ps4:ps4" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Symlink the GAMES drive (failsafe if udev is slow)
mkdir -p /mnt/games
ln -sfn /mnt/games /home/ps4/games
chown -h ps4:ps4 /home/ps4/games

# Fix Line Endings and Permissions for our custom scripts
for script in /usr/local/bin/kiosk-loop.sh /usr/local/bin/ps4-launch; do
    if [ -f "$script" ]; then
        sed -i 's/\r$//' "$script"
        chmod +x "$script"
    fi
done

# Extract shadPS4 from the tarball
if [ -f /var/localrepo/shadps4-custom.tar.gz ]; then
    tar -xzf /var/localrepo/shadps4-custom.tar.gz -C /
    chmod +x /usr/bin/shadps4
fi

echo "Customization complete."
