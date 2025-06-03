#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

apt update && apt upgrade -y

rm -rf blockmesh-cli.tar.gz target

if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
else
    echo "Docker is already installed, skipping..."
fi

if ! command -v docker-compose &>/dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose.tmp
    if [[ -f /usr/local/bin/docker-compose ]]; then
        rm /usr/local/bin/docker-compose
    fi
    mv /usr/local/bin/docker-compose.tmp /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose is already installed, skipping..."
fi

mkdir -p target/release

echo "Downloading and extracting BlockMesh CLI..."
curl -s https://api.github.com/repos/block-mesh/block-mesh-monorepo/releases/latest |
    grep -oP '"browser_download_url": "\K(.*blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz)' |
    xargs curl -L -o blockmesh-cli.tar.gz
tar -xzf blockmesh-cli.tar.gz --strip-components=3 -C target/release

if [[ ! -f target/release/blockmesh-cli ]]; then
    echo "Error: blockmesh-cli binary not found in target/release. Exiting..."
    exit 1
fi

read -p "Enter your BlockMesh email: " email
read -s -p "Enter your BlockMesh password: " password
echo

if ! docker ps --filter "name=blockmesh-cli-container" | grep -q 'blockmesh-cli-container'; then
    echo "Creating a Docker container for the BlockMesh CLI..."
    docker run -it --rm \
        --name blockmesh-cli-container \
        -v $(pwd)/target/release:/app \
        -e EMAIL="$email" \
        -e PASSWORD="$password" \
        --workdir /app \
        ubuntu:22.04 ./blockmesh-cli --email "$email" --password "$password"
else
    echo "BlockMesh CLI container is already running, restarting to use the new binary"
    docker restart blockmesh-cli-container
fi
