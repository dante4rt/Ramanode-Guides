#!/bin/bash

wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh

clear
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Installing Node.js and npm..."
./loader.sh "sudo apt update && sudo apt install nodejs npm -y" "..." "Installing Node.js and npm"

echo "Installing snarkjs..."
./loader.sh "sudo npm install -g snarkjs" "..." "Installing snarkjs"

if [ ! -f Owshen_v0.1.3_x86_64.AppImage ]; then
    echo "Downloading Owshen Wallet..."
    ./loader.sh "wget https://github.com/OwshenNetwork/owshen/releases/download/v0.1.3/Owshen_v0.1.3_x86_64.AppImage && chmod +x Owshen_v0.1.3_x86_64.AppImage" "..." "Downloading and setting up Owshen Wallet"
else
    echo "Owshen Wallet AppImage already downloaded."
    chmod +x Owshen_v0.1.3_x86_64.AppImage
fi

initialize_wallet() {
    read -p "Enter your 12-word mnemonic phrase: " MNEMONIC
    if ./Owshen_v0.1.3_x86_64.AppImage init --mnemonic "$MNEMONIC"; then
        echo "Wallet initialized successfully."
    else
        echo "Failed to initialize wallet. FUSE might not be supported in this environment."
    fi
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
if ./Owshen_v0.1.3_x86_64.AppImage wallet; then
    echo "Owshen Wallet launched successfully."
else
    echo "Failed to launch Owshen Wallet. FUSE might not be supported in this environment."
fi
