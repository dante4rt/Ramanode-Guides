#!/bin/bash

sudo apt update && sudo apt upgrade -y

if ! command -v rustc &> /dev/null
then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    echo "Rust is already installed."
fi

rustc --version

if ! command -v solana &> /dev/null
then
    echo "Installing Solana CLI..."
    sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
    export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
else
    echo "Solana CLI is already installed."
fi

solana --version

sudo apt-get update
sudo apt-get install -y nodejs npm
npm install --global yarn

node -v
npm --version
yarn --version

if ! command -v anchor &> /dev/null
then
    echo "Installing Anchor..."
    cargo install --git https://github.com/project-serum/anchor anchor-cli --locked
else
    echo "Anchor is already installed."
fi

anchor --version

if [ ! -f "$HOME/my-wallet.json" ]; then
    echo "Creating a new Solana wallet..."
    solana-keygen new -o $HOME/my-wallet.json
else
    echo "Solana wallet already exists."
fi

solana config set --url https://testnet.dev2.eclipsenetwork.xyz/
solana config set --keypair $HOME/my-wallet.json

SOLANA_ADDRESS=$(solana address)
echo "Solana Address: $SOLANA_ADDRESS"

echo "Import the same seedphrase to Metamask/Rabby Wallet to use it for Ethereum Sepolia."

echo "Request Sepolia gas from the following faucets:"
echo "MINE SEPOLIA GAS: https://sepolia-faucet.pk910.de/"
echo "Quicknode: https://faucet.quicknode.com/ethereum/sepolia"


if [ ! -d "testnet-deposit" ]; then
    echo "Cloning Eclipse Bridge Script..."
    git clone https://github.com/Eclipse-Laboratories-Inc/testnet-deposit
    cd testnet-deposit
    npm install
else
    echo "Eclipse Bridge Script already cloned."
    cd testnet-deposit
fi

if ! command -v nvm &> /dev/null
then
    echo "Installing nvm and updating Node.js..."
    sudo apt-get remove -y nodejs
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    source ~/.bashrc
    nvm install --lts
    nvm use --lts
else
    echo "nvm is already installed."
fi

node -v

read -p "Enter the Ethereum Private Key: " ETH_PRIVATE_KEY
read -p "Enter the Sepolia RPC Endpoint: " SEPOLIA_RPC

node deposit.js $SOLANA_ADDRESS 0x7C9e161ebe55000a3220F972058Fb83273653a6e 3000000 100000 $ETH_PRIVATE_KEY $SEPOLIA_RPC


solana balance

TOKEN_ADDRESS=$(spl-token create-token --enable-metadata -p TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb | grep -o 'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb')

spl-token create-account $TOKEN_ADDRESS
spl-token mint $TOKEN_ADDRESS 10000

spl-token accounts


