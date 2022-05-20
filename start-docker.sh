#!/usr/bin/env bash
WSL=$(if grep -q microsoft /proc/version; then echo 'true'; else echo 'false'; fi)

if [ $WSL == 'true' ]; then
    sudo /etc/init.d/docker start
else
    sudo systemctl start containerd
    sudo systemctl start docker.service
    sudo systemctl start docker.socket
fi
