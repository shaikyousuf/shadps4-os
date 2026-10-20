#!/bin/bash
set -e -u

# 1. Assign absolute groups ensuring seatd integration
useradd -m -g users -G audio,video,input,render,seat,wheel -s /bin/bash ps4
echo "ps4:ps4" | chpasswd

# 2. Resolve the mkarchiso root node permission issue (FIXED GROUP)
chown -R ps4:users /home/ps4

# 3. Global runtime permission assurance
chmod +x /usr/local/bin/kiosk-loop.sh
chmod +x /usr/local/bin/ps4-launch

# 4. Enable system services
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable bluetooth.service
systemctl enable seatd.service
systemctl mask archinstall.service || true
systemctl mask systemd-firstboot.service || true

# 5. Configure sudoers elevation
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# 6. Symlink GAMES drive and extract shadPS4
mkdir -p /mnt/games
ln -sfn /mnt/games /home/ps4/games
chown -h ps4:users /home/ps4/games # FIXED GROUP

if [ -f /var/localrepo/shadps4-custom.tar.gz ]; then
    tar -xzf /var/localrepo/shadps4-custom.tar.gz -C /
    chmod +x /usr/bin/shadps4
fi

# 7. CRITICAL ARCHISO FIX: Force DKMS compilation and Module Re-indexing
ZEN_KERN_VER=$(ls /lib/modules | grep zen | head -n 1)
if [ -n "$ZEN_KERN_VER" ]; then
    echo "==> Compiling NVIDIA modules for kernel: $ZEN_KERN_VER"
    dkms autoinstall -k "$ZEN_KERN_VER"
    echo "==> Re-indexing kernel module dependencies..."
    depmod -a "$ZEN_KERN_VER"
else
    echo "==> ERROR: Could not detect linux-zen kernel version in /lib/modules!"
    exit 1
fi

echo "Customization complete."
