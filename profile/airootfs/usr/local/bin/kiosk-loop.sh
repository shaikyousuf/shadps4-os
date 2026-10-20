#!/bin/bash

# 1. Wait for GAMES drive (Max 30s)
echo "Waiting for /mnt/games to mount..."
for i in {1..30}; do
    if mountpoint -q /mnt/games || [ -d "/mnt/games/PS4" ]; then
        echo "Drive mounted!"
        break
    fi
    sleep 1
done

# 2. Wait for seatd socket (Max 10s)
echo "Waiting for seatd..."
for i in {1..10}; do
    if [ -S /run/seatd.sock ]; then
        echo "Seatd ready!"
        break
    fi
    sleep 1
done

# 3. Force libseat to use seatd
export LIBSEAT_BACKEND=seatd

# 4. Secure execution runtime path
export XDG_RUNTIME_DIR=/run/user/$(id -u)
if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
fi

# 5. Corrected Graphics Execution Variables (Intel for cage)
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland

# 6. Infinite Execution Watchdog with Crash Safeguard
CRASH_COUNT=0

while true; do
    if [ -f "/usr/local/bin/ps4-launch" ]; then
        echo "Starting shadPS4 Console..."
        
        START_TIME=$(date +%s)
        cage -s -- /usr/local/bin/ps4-launch
        END_TIME=$(date +%s)
        RUNTIME=$((END_TIME - START_TIME))
        
        if [ "$RUNTIME" -lt 10 ]; then
            CRASH_COUNT=$((CRASH_COUNT + 1))
            echo "WARNING: Cage crashed in $RUNTIME seconds. (Crash Count: $CRASH_COUNT/3)"
        else
            CRASH_COUNT=0
        fi
        
        if [ "$CRASH_COUNT" -ge 3 ]; then
            echo "=========================================================="
            echo "CRITICAL: Cage crashed 3 times rapidly. Loop halted."
            echo "Switch to TTY2 (Ctrl+Alt+F2) and log in as 'ps4' to debug."
            echo "Password: ps4"
            echo "=========================================================="
            while true; do sleep 3600; done
        fi
    else
        echo "CRITICAL ERROR: /usr/local/bin/ps4-launch missing or unreadable!"
        while true; do sleep 3600; done
    fi
    
    echo "Cage session exited. Restarting in 3 seconds..."
    sleep 3
done
