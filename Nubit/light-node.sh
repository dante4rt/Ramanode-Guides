#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

cd $HOME || exit 1

sudo apt update && sudo apt upgrade -y || exit 1

sudo apt install -y tmux || exit 1

sudo echo "deb http://security.ubuntu.com/ubuntu jammy-security main" >> /etc/apt/sources.list
sudo apt -qy update && sudo apt -qy install libc6 || exit 1

rm -rf nubit-node

tmux new -s nubit "curl -sL1 https://nubit.sh | bash" || exit 1

echo "Script execution completed successfully. Subscribe: https://t.me/HappyCuanAirdrop"
