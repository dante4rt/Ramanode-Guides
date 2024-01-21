#!/bin/bash

wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh

clear
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Installing libfuse2 and nodejs..."
./loader.sh "sudo apt update && sudo apt install fuse libfuse2 nodejs -y" "..." "Updating and installing packages"

echo "Installing snarkjs..."
./loader.sh "sudo npm install -g snarkjs" "..." "Installing snarkjs"

echo "Downloading Owshen Wallet..."
wget https://github.com/OwshenNetwork/owshen/releases/download/v0.1.3/Owshen_v0.1.3_x86_64.AppImage
chmod +x Owshen_v0.1.3_x86_64.AppImage
./loader.sh "echo 'AppImage downloaded and made executable'" "..." "Preparing Owshen Wallet"

initialize_wallet() {
    read -p "Enter your 12-word mnemonic phrase: " MNEMONIC
    ./Owshen_v0.1.3_x86_64.AppImage init --mnemonic "$MNEMONIC"
}

if [ ! -f ~/.owshen-wallet ]; then
    echo "Initializing Owshen Wallet..."
    initialize_wallet
else
    echo "Owshen Wallet is already initialized."
    read -p "Do you want to reinitialize your wallet? This will remove your current wallet files (y/n): " REINIT
    if [[ $REINIT =~ ^[Yy]$ ]]; then
        echo "Removing old wallet files..."
        rm -rf ~/.owshen-wallet
        rm -rf ~/.owshen-wallet-cache
        initialize_wallet
    fi
fi

echo "Running Owshen Wallet..."
./loader.sh "./Owshen_v0.1.3_x86_64.AppImage wallet" "..." "Launching Owshen Wallet"
