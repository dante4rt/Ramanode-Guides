#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Welcome to the Nillion Verifier auto-installer by Happy Cuan Airdrop"
echo ""

cd $HOME

while true; do
    echo "1. Visit: https://verifier.nillion.com/verifier, Connect your Keplr wallet, then click Verifier"
    echo "2. Fund your connected wallet with NIL (Request Faucet here https://faucet.testnet.nillion.com/)"
    read -p "Have you already funded your wallet? (y/n): " funded_wallet
    if [ "$funded_wallet" == "y" ]; then
        break
    else
        echo "Waiting for you to fund your wallet..."
    fi
done

echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y screen jq

if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Installing Docker version 27.1.1, build 63125853e3..."
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update
    sudo apt install -y docker-ce=5:27.1.1~3-0~ubuntu-$(lsb_release -cs) docker-ce-cli=5:27.1.1~3-0~ubuntu-$(lsb_release -cs) containerd.io
else
    echo "Docker is already installed, skipping installation..."
fi

echo "Pulling the accuser image from Docker Hub..."
docker pull nillion/retailtoken-accuser:v1.0.1

echo "Initializing the accuser..."
mkdir -p nillion/accuser
docker run -v $(pwd)/nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.1 initialise

echo "Displaying accuser credentials:"
credentials_file="nillion/accuser/credentials.json"
if [ -f "$credentials_file" ]; then
    address=$(jq -r '.address' $credentials_file)
    pub_key=$(jq -r '.pub_key' $credentials_file)
    echo "Address: $address"
    echo "Public Key: $pub_key"
else
    echo "credentials.json not found!"
fi

while true; do
    echo "Please copy your account_id and public_key to https://verifier.nillion.com/verifier."
    read -p "Have you completed this step? (y/n): " copied_details
    if [ "$copied_details" == "y" ]; then
        break
    else
        echo "Waiting for you to copy your account_id and public_key..."
    fi
done

while true; do
    echo "Please fund your accuser address (account_id) on https://faucet.testnet.nillion.com/."
    read -p "Have you funded your accuser address? (y/n): " funded_accuser
    if [ "$funded_accuser" == "y" ]; then
        break
    else
        echo "Waiting for you to fund your accuser address..."
    fi
done

current_height=$(curl -s https://testnet-nillion-rpc.lavenderfive.com/abci_info | jq -r '.result.response.last_block_height')
block_start=$((current_height - 100))

echo "Automatically determined block start is $block_start"

sleep_time=$((30 + RANDOM % 31))m
echo "Sleeping for $sleep_time..."
sleep $sleep_time

echo "Running the accuser..."
docker run -v $(pwd)/nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.1 accuse --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com" --block-start $block_start

echo "The accuser is now running and will automatically accuse once the registration event is posted to the chain."
echo "Subscribe: https://t.me/HappyCuanAirdrop."
