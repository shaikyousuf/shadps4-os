#!/bin/bash
case "$1" in
    post)
        if [ -x /usr/bin/nvidia-smi ]; then
            /usr/bin/nvidia-smi -q > /dev/null 2>&1
        fi
        ;;
esac
