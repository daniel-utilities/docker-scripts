

# Prereqs
function install_prerequisites() {
    local -a packages=(
        ca-certificates
        curl
        gnupg
        lsb-release
    )

    echo ""
    echo "The following APT packages will be installed:" 
    echo "${packages[@]}"
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    sudo apt-get update
    sudo apt-get install -y ${packages[@]}
}

# Download and run convenience script
function run_docker_script() {
    local url='https://get.docker.com'
    local filename='/tmp/get-docker.sh'

    echo ""
    echo "The following file will be downloaded and run:" 
    echo "  $url"
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""
    curl -fsSL $url -o "$filename"
    sudo sh "$filename"
    rm "$filename"
}

# Add user to "docker" group
function set_group() {
    echo ""
    echo "The 'docker' group will be created and user $USER will be added to it." 
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER"

    echo ""
    echo "$USER will be given ownership of $HOME/.docker." 
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""
    sudo chown "$USER":"$USER" "$HOME/.docker" -R
    sudo chmod g+rwx "$HOME/.docker" -R
    sudo chmod 666 /var/run/docker.sock
}

# Set docker to run automatically
function enable_services() {
    if is_systemd; then
        local -a services=(
            udev
            docker.service
            docker.socket
            containerd.service
        )
        local fncall='sysd_config_system_service'
    else
        local -a services=(
            udev
            docker
        )
        local fncall='sysv_config_user_service'
    fi

    echo ""
    echo "The following services will be started automatically on boot:" 
    print_arr services
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    for service in "${services[@]}"; do
        $fncall $service enable start
    done

    sudo udevadm control --reload-rules
    sudo udevadm trigger
}


# Test docker installation
function test_docker() {
    local image="hello-world"
    echo ""
    echo "The following Docker image will be downloaded and run:" 
    echo "$image"
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    docker run "$image"
}
