#!/bin/bash
set -e

if [[ -n "$PUBLIC_KEY" ]]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi

mkdir -p /run/sshd
ssh-keygen -A
/usr/sbin/sshd -D -e &

echo "----------------------------------------------------------"
echo " DX Challenge - Motion Planning"
echo " OS       : $(. /etc/os-release && echo "$PRETTY_NAME")"
echo " Python   : $(python3 --version 2>&1)"
echo " uv       : $(uv --version 2>&1)"
echo " Driver   : $(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo 'none')"
echo "----------------------------------------------------------"

sleep infinity
