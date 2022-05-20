#!/usr/bin/env bash
WSL=$(if grep -q microsoft /proc/version; then echo 'true'; else echo 'false'; fi)

if [ $WSL == 'true' ]; then
    sudo /etc/init.d/docker stop
else
    sudo systemctl stop containerd
    sudo systemctl stop docker.service
    sudo systemctl stop docker.socket
fi
