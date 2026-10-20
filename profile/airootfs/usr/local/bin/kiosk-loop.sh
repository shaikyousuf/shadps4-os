#!/bin/bash

# 1. Wait for the GAMES drive to mount (Max 30 seconds)
echo "Waiting for /mnt/games to mount..."
for i in {1..30}; do
    if mountpoint -q /mnt/games || [ -d "/mnt/games/PS4" ]; then
        echo "Drive mounted!"
        break
    fi
    sleep 1
done

# 2. Wait for seatd socket to exist (Max 10 seconds)
echo "Waiting for seatd..."
for i in {1..10}; do
    if [ -S /run/seatd.sock ]; then
        echo "Seatd ready!"
        break
    fi
    sleep 1
done

# 3. Force libseat to use the seatd backend
export LIBSEAT_BACKEND=seatd

# 4. Ensure Wayland runtime directory exists and is owned by ps4
export XDG_RUNTIME_DIR=/run/user/1000
mkdir -p "$XDG_RUNTIME_DIR"
chown ps4:ps4 "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"

# 5. Set NVIDIA and Wayland variables
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export __NV_PRIME_RENDER_OFFLOAD=1
export __VK_LAYER_NV_optimus=NVIDIA_only
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

# 6. Infinite Kiosk Loop
while true; do
    echo "Starting shadPS4 Console..."
    cage -s -- /usr/local/bin/ps4-launch
    
    echo "Cage exited. Restarting in 3 seconds..."
    sleep 3
done
