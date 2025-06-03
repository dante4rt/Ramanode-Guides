#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Welcome to the Ollama/OpenAI setup script!"

sudo apt update && sudo apt upgrade -y

echo "Checking if Screen is installed..."
if ! command -v screen &>/dev/null; then
    sudo apt install screen -y
fi

echo "Checking if Docker is installed..."
if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt update && sudo apt install -y docker.io
else
    echo "Docker is already installed."
fi
docker --version

VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/${VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Cloning the node repository..."
git clone https://github.com/firstbatchxyz/dkn-compute-node

echo "Navigating to the node directory..."
cd dkn-compute-node

echo "Creating .env file..."
cp .env.example .env

read -sp "Please enter your Ethereum Wallet private key: " PRIVATE_KEY
echo
echo "DKN_WALLET_SECRET_KEY=$PRIVATE_KEY" >>.env
echo "Your private key has been added to the .env file."

read -p "Do you want to use Ollama or OpenAI? (ollama/openai): " AI_PROVIDER

if [ "$AI_PROVIDER" = "openai" ]; then
    read -sp "Please enter your OpenAI API key: " OPENAI_API_KEY
    echo
    echo "OPENAI_API_KEY=$OPENAI_API_KEY" >>.env
    echo "Your OpenAI API key has been added to the .env file."

    echo "Please select a model from the following list:"
    echo "1) gpt-4o-mini (Lowest cost)"
    echo "2) gpt-4o (Price-efficient)"
    echo "3) gpt-3.5-turbo"
    echo "4) gpt-4-turbo"
    read -p "Enter the number corresponding to your choice: " MODEL_CHOICE

    case $MODEL_CHOICE in
    1)
        MODEL="gpt-4o-mini"
        ;;
    2)
        MODEL="gpt-4o"
        ;;
    3)
        MODEL="gpt-3.5-turbo"
        ;;
    4)
        MODEL="gpt-4-turbo"
        ;;
    *)
        echo "Invalid selection. Defaulting to gpt-4o-mini."
        MODEL="gpt-4o-mini"
        ;;
    esac
elif [ "$AI_PROVIDER" = "ollama" ]; then
    echo "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh

    echo "Please select a model from the following list:"
    echo "1) adrienbrault/nous-hermes2theta-llama3-8b:q8_0"
    echo "2) phi3:14b-medium-4k-instruct-q4_1"
    echo "3) phi3:14b-medium-128k-instruct-q4_1"
    echo "4) phi3:3.8b"
    echo "5) llama3.1:latest"
    read -p "Enter the number corresponding to your choice: " MODEL_CHOICE

    case $MODEL_CHOICE in
    1)
        MODEL="adrienbrault/nous-hermes2theta-llama3-8b:q8_0"
        ;;
    2)
        MODEL="phi3:14b-medium-4k-instruct-q4_1"
        ;;
    3)
        MODEL="phi3:14b-medium-128k-instruct-q4_1"
        ;;
    4)
        MODEL="phi3:3.8b"
        ;;
    5)
        MODEL="llama3.1:latest"
        ;;
    *)
        echo "Invalid selection. Defaulting to llama3.1:latest."
        MODEL="llama3.1:latest"
        ;;
    esac
else
    echo "Invalid provider selection. Exiting."
    exit 1
fi

echo "Setting up the node with the model: $MODEL"
chmod +x start.sh
./start.sh -m="$MODEL"

echo "Setup complete. Your node is now running with the selected model."
echo "Subscribe: https://t.me/HappyCuanAirdrop."
