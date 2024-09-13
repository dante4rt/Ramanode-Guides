#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

sudo apt update && sudo apt upgrade -y

if ! command -v screen &> /dev/null
then
    echo "Installing screen..."
    sudo apt install screen -y
fi

cd $HOME
if [ ! -d "hca-autonomys" ]; then
    mkdir hca-autonomys
    echo "Created hca-autonomys directory."
fi
cd hca-autonomys

wget https://github.com/autonomys/subspace/releases/download/gemini-3h-2024-sep-03/subspace-farmer-ubuntu-x86_64-skylake-gemini-3h-2024-sep-03
chmod +x subspace-farmer-ubuntu-x86_64-skylake-gemini-3h-2024-sep-03

read -p "Enter your WALLET_ADDRESS: " WALLET_ADDRESS
read -p "Enter plot size (default 10GB, min 10GB, max 200TiB): " PLOT_SIZE
PLOT_SIZE=${PLOT_SIZE:-10GB}

mkdir -p $HOME/hca-autonomys/farmer-db

./subspace-farmer-ubuntu-x86_64-skylake-gemini-3h-2024-sep-03 farm \
  --reward-address "$WALLET_ADDRESS" \
  path="$HOME/hca-autonomys/farmer-db",size="$PLOT_SIZE"
