#!/bin/bash

echo "=== 1. Mounting GAMES drive ==="
mkdir -p /mnt/games
if ! mountpoint -q /mnt/games; then
    GAMES_DEV=$(blkid -L GAMES)
    if [ -n "$GAMES_DEV" ]; then
        mount -t ntfs3 -o ro "$GAMES_DEV" /mnt/games
        echo "Mounted $GAMES_DEV to /mnt/games"
    else
        echo "ERROR: Could not find partition labeled GAMES"
        exit 1
    fi
fi

echo "=== 2. Linking Firmware and Games ==="
mkdir -p /root/.config/shadps4 /root/.local/share/shadPS4
ln -sfn /mnt/games/sys_modules /root/.config/shadps4/sys_modules
ln -sfn /mnt/games/PS4 /root/.local/share/shadPS4/games

echo "=== 3. Setting Graphics Variables ==="
export APPIMAGE_EXTRACT_AND_RUN=1
export XDG_RUNTIME_DIR=/tmp
export QT_QPA_PLATFORM=xcb
export __NV_PRIME_RENDER_OFFLOAD=1
export __VK_LAYER_NV_optimus=NVIDIA_only
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/intel_icd.json

echo "=== 4. Launching UI ==="
xinit /opt/shadps4/shadps4 -b
