# Auto-fix script for shadps4-os kiosk architecture
Write-Host "Creating required directories..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "usr\local\bin", "etc\tmpfiles.d", "root" | Out-Null

Write-Host "1. Writing usr/local/bin/ps4-launch..." -ForegroundColor Green
$launcherContent = @'
#!/bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR=/run/user/$(id -u)

SHADPS4_BIN="/usr/bin/shadps4"
CONFIG_DIR="/home/ps4/.local/share/shadPS4"
CONFIG_FILE="$CONFIG_DIR/config.toml"

mkdir -p "$CONFIG_DIR/sys_modules"

if [ ! -f "$CONFIG_FILE" ]; then
    cat <<EOF > "$CONFIG_FILE"
[General]
Fullscreen = true
isNeo = false

[GUI]
gamedirs = ["/mnt/games/PS4"]
EOF
fi

LOG_DIR="/home/ps4/.local/share/shadPS4/logs"
if mountpoint -q /mnt/games || [ -d "/mnt/games/PS4" ]; then
    LOG_DIR="/mnt/games/logs"
fi
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/crash_$(date +%Y%m%d_%H%M%S).log"

stdbuf -oL -eL env \
    __NV_PRIME_RENDER_OFFLOAD=1 \
    __VK_LAYER_NV_optimus=NVIDIA_only \
    __GLX_VENDOR_LIBRARY_NAME=nvidia \
    VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/intel_icd.json \
    $SHADPS4_BIN "$@" 2>&1 | tee -a "$LOG_FILE" || true
'
Set-Content -Path "usr\local\bin\ps4-launch" -Value $launcherContent -Encoding UTF8

Write-Host "2. Writing etc/tmpfiles.d/shadps4.conf..." -ForegroundColor Green
$tmpfilesContent = @'
# /etc/tmpfiles.d/shadps4.conf
d /run/user 0755 root root -
d /run/user/1000 0755 ps4 users -
'
Set-Content -Path "etc\tmpfiles.d\shadps4.conf" -Value $tmpfilesContent -Encoding UTF8

Write-Host "3. Updating root/customize_airootfs.sh..." -ForegroundColor Green
$hookContent = @"
# Ensure shadPS4 directory structure exists for user ps4
mkdir -p /home/ps4/.local/share/shadPS4/sys_modules
chown -R ps4:users /home/ps4/.local/share/shadPS4
"@
Add-Content -Path "root\customize_airootfs.sh" -Value $hookContent

Write-Host "All fixes applied successfully! Now running git commit..." -ForegroundColor Yellow
git add usr/local/bin/ps4-launch etc/tmpfiles.d/shadps4.conf root/customize_airootfs.sh
git commit -m "fix(kiosk): automated fix for sys_modules bounds, headless launch, and volatile run dirs"

Write-Host "Done! Your repository is updated and committed locally." -ForegroundColor Cyan