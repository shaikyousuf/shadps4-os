#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="shadps4-console"
iso_label="SHADPS4_$(date +%Y%m)"
iso_publisher="Custom Arch Linux <https://archlinux.org>"
iso_application="shadPS4 Emulation Console"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('uefi.grub')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/ps4-launch"]="0:0:755"
)
