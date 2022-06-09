#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
WSL=$(if grep -q microsoft /proc/version; then echo 'true'; else echo 'false'; fi)

# Prereqs
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Download and run convenience script
echo "Downloading install script from get.docker.com..."
cd "$SCRIPT_DIR"
curl -fsSL https://get.docker.com -o get-docker.sh
chmod +x get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Add user to "docker" group
echo "Adding $USER to group 'docker'"
sudo groupadd -f docker
sudo usermod -aG docker $USER

# Set docker to run automatically
echo "Setting docker service to start automatically on login"
if [ $WSL == 'true' ]; then
    # Give user permissions to start Docker init.d service
    echo "Adding /etc/init.d/docker to /etc/sudoers..."
    APPEND="$USER ALL=(ALL) NOPASSWD: /etc/init.d/docker"
    if [ -z "$(sudo grep "$APPEND" /etc/sudoers )" ]; then
        echo "$APPEND" | sudo EDITOR='tee -a' visudo
    fi

    # Set ./profile to start docker service
    APPEND="sudo /etc/init.d/docker start & disown"
    FILE="$HOME/.profile"
    grep -qxF "$APPEND" "$FILE" || echo "$APPEND" | tee -a "$FILE" > /dev/null
    
    # Set /etc/wsl.conf to start docker service
    # APPEND="[boot]\ncommand = service docker start"
    # FILE="/etc/wsl.conf"
    # if ! grep -qxF "[boot]" "$FILE"; then
    #     echo -e "$APPEND" | sudo tee -a "$FILE" > /dev/null
    # else
    #     NEED_MANUAL="true"
    # fi
else
    sudo systemctl enable docker.service
    sudo systemctl enable docker.socket
    sudo systemctl enable containerd.service
fi

# Start docker
echo "Starting Docker services"
if [ "$WSL" == 'true' ]; then
    sudo /etc/init.d/docker start
else
    sudo systemctl start containerd
    sudo systemctl start docker.service
    sudo systemctl start docker.socket
fi

# Give user permissions to docker files
echo "Setting user permissions"
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
sudo chmod 666 /var/run/docker.sock
sudo service udev restart
sudo udevadm control --reload-rules && sudo udevadm trigger

# Test docker installation
echo "Testing docker install..."
docker run hello-world

if [ "$NEED_MANUAL" == 'true' ]; then
    echo "WARNING: /etc/wsl.conf already contains a [boot] section."
    echo "Please add the following to the 'command = ...' line in /etc/wsl.conf:"
    echo "  service docker start"
    echo " "
fi

