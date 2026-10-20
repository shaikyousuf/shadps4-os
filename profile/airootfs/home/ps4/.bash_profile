# Ensure standard system pathways are populated
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# Force execution of the Wayland kiosk environment loops securely
if [ "$(tty)" = "/dev/tty1" ]; then
    exec /usr/local/bin/kiosk-loop.sh
fi
