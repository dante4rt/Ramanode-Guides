#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

WORKDIR=$(pwd)

read -sp 'Enter your private key: ' PRIVATE_KEY
echo

read -p 'Enter your EVM wallet address: ' EVM_WALLET_ADDRESS
echo

echo -e "\033[1;34mInstalling ethfs-cli...\033[0m"
npm install -g ethfs-cli || { echo "Failed to install ethfs-cli"; exit 1; }

echo -e "\033[1;34mInstalling eth-blob-uploader...\033[0m"
npm install -g eth-blob-uploader || { echo "Failed to install eth-blob-uploader"; exit 1; }

echo -e "\033[1;34mCreating a filesystem with ethfs-cli...\033[0m"
echo -e "\033[1;35mCOPY THIS DIRECTORY ADDRESS AND SAVE IT SOMEWHERE\033[0m"
ethfs-cli create -p "$PRIVATE_KEY" -c 3333 || { echo "Failed to create filesystem with ethfs-cli"; exit 1; }
echo

read -p 'Enter the flat directory address: ' FLAT_DIR_ADDRESS
echo

echo -e "\033[1;34mUploading 'hca' folder with ethfs-cli...\033[0m"
ethfs-cli upload -f "$WORKDIR/hca" -a "$FLAT_DIR_ADDRESS" -c 3333 -p "$PRIVATE_KEY" -t 2 || { echo "Failed to upload folder with ethfs-cli"; exit 1; }
echo

echo -e "\033[1;34mUploading 'app.html' with eth-blob-uploader...\033[0m"
eth-blob-uploader -r http://88.99.30.186:8545 -p "$PRIVATE_KEY" -f "$WORKDIR/hca/app.html" -t "$EVM_WALLET_ADDRESS" || { echo "Failed to upload app.html with eth-blob-uploader"; exit 1; }
echo

echo -e "\033[1;34mCreating a new filesystem again with ethfs-cli...\033[0m"
echo -e "\033[1;35mCOPY THIS DIRECTORY ADDRESS AND SAVE IT SOMEWHERE\033[0m"
ethfs-cli create -p "$PRIVATE_KEY" -c 3333 || { echo "Failed to create filesystem with ethfs-cli"; exit 1; }
echo

read -p 'Enter the flat directory address: ' FLAT_DIR_ADDRESS2
echo

echo -e "\033[1;34mUploading 'hca' folder again with ethfs-cli...\033[0m"
echo -e "\033[1;31mThis transaction may get stuck. You should wait 2 minutes. If it is still the same, start the script from the beginning\033[0m"
ethfs-cli upload -f "$WORKDIR/hca" -a "$FLAT_DIR_ADDRESS2" -c 3333 -p "$PRIVATE_KEY" -t 2 || { echo "Failed to upload folder with ethfs-cli"; exit 1; }
echo

echo -e "\033[1;32mThis is your application’s web3 link:\033[0m https://"$FLAT_DIR_ADDRESS2".3333.w3link.io/app.html"
echo

echo -e "\033[1;32mAll tasks completed successfully.\033[0m"
echo
