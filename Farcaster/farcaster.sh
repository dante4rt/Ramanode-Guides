#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

sudo apt update && sudo apt upgrade -y

sudo apt install make clang pkg-config libssl-dev libclang-dev build-essential git curl ntp jq llvm tmux htop screen unzip cmake cron -y

if ! command -v go &>/dev/null; then
    echo "Golang not found. Installing Golang..."
    . <(wget -qO- https://raw.githubusercontent.com/letsnode/Utils/main/installers/golang.sh)
else
    echo "Golang is already installed. Skipping installation..."
fi

if ! command -v docker &>/dev/null; then
    echo "Docker not found. Installing Docker..."
    . <(wget -qO- https://raw.githubusercontent.com/letsnode/Utils/main/installers/docker.sh)
else
    echo "Docker is already installed. Skipping installation..."
fi

curl -sSL https://download.thehubble.xyz/bootstrap.sh | bash
