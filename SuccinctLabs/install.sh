#!/bin/bash

echo "Starting setup and proof process..."

if [ ! -f "loader.sh" ]; then
    echo "Showing HCA logo..."
    wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh
    chmod +x loader.sh
else
    echo "loader.sh from HCA already exists. Skipping download."
fi

./loader.sh

echo "Installing Git..."
sudo apt update && sudo apt install -y git-all build-essential gcc cargo pkg-config libssl-dev
git --version

echo "Checking if Rust is installed..."
if ! command -v rustc &> /dev/null; then
    echo "Rust is not installed. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    echo "Rust installed. Reconfiguring PATH..."
    . "$HOME/.cargo/env"
else
    echo "Rust is already installed."
fi

echo "Checking if Docker is installed..."
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt update && sudo apt install -y docker.io
else
    echo "Docker is already installed."
fi
docker --version

echo "Creating new project 'fibonacci'..."
cargo prove new fibonacci
cd fibonacci || { echo "Failed to change directory to 'fibonacci'"; exit 1; }

echo "Executing Proof..."
if [ -d "script" ]; then
    cd script || { echo "Failed to change directory to 'script'"; exit 1; }
    
    echo "Running proof execution..."
    RUST_LOG=info cargo run --release -- --execute
    echo "Proof execution completed successfully."
    
    echo "Generating Proof..."
    RUST_LOG=info cargo run --release -- --prove
    echo "Proof generated and verified successfully."
else
    echo "Directory 'script' not found. Ensure the project was set up correctly."
    exit 1
fi

echo "Process completed successfully."
echo "Subscribe: https://t.me/HappyCuanAirdrop"
