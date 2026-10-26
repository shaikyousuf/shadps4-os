
#!/bin/bash

echo "=== [1/5] Cleaning up old processes ==="
pkill -9 shadps4 2>/dev/null || true
pkill -9 Xorg 2>/dev/null || true

echo "=== [2/5] Setting up 4GB RAM disk for /tmp ==="
umount /tmp 2>/dev/null || true
rm -rf /tmp/*
mount -t tmpfs -o size=4G tmpfs /tmp

echo "=== [3/5] Mounting GAMES drive safely ==="
mkdir -p /mnt/games
umount /mnt/games 2>/dev/null || true
GAMES_DEV=$(blkid -L GAMES)
if [ -z "$GAMES_DEV" ]; then
    echo "ERROR: Could not find partition labeled GAMES."
    exit 1
fi
mount -t ntfs3 -o ro "$GAMES_DEV" /mnt/games
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to mount $GAMES_DEV."
    exit 1
fi
echo "Mounted $GAMES_DEV to /mnt/games"

echo "=== [4/5] Linking Firmware and Games ==="
# Clean up any old broken links to prevent nesting
rm -rf /root/.config/shadps4/sys_modules
mkdir -p /root/.config/shadps4
ln -sfn /mnt/games/sys_modules /root/.config/shadps4/sys_modules

rm -rf /root/.local/share/shadPS4/games
mkdir -p /root/.local/share/shadPS4
ln -sfn /mnt/games/PS4 /root/.local/share/shadPS4/games

echo "=== [5/5] Launching UI ==="
export APPIMAGE_EXTRACT_AND_RUN=1
export XDG_RUNTIME_DIR=/tmp
export QT_QPA_PLATFORM=xcb
export __NV_PRIME_RENDER_OFFLOAD=1
export __VK_LAYER_NV_optimus=NVIDIA_only
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/intel_icd.json

xinit /opt/shadps4/shadps4 -b
