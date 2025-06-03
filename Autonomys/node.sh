#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

sudo apt update && sudo apt upgrade -y

if ! command -v screen &>/dev/null; then
    echo "Installing screen..."
    sudo apt install screen -y
fi

cd $HOME
if [ ! -d "hca-autonomys" ]; then
    mkdir hca-autonomys
    echo "Created hca-autonomys directory."
fi
cd hca-autonomys
rm -rf node-db subspace-node-ubuntu-x86_64-skylake-gemini-3h-2024-sep-03

wget https://github.com/autonomys/subspace/releases/download/gemini-3h-2024-sep-03/subspace-node-ubuntu-x86_64-skylake-gemini-3h-2024-sep-03
chmod +x subspace-node-ubuntu-x86_64-skylake-gemini-3h-2024-sep-03

read -p "Enter your NODE_NAME: " NODE_NAME
mkdir -p $HOME/hca-autonomys/node-db

./subspace-node-ubuntu-x86_64-skylake-gemini-3h-2024-sep-03 \
    run \
    --chain gemini-3h \
    --base-path "$HOME/hca-autonomys/node-db" \
    --name "$NODE_NAME" \
    --farmer
