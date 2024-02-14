#!/bin/bash

# Change to the user's home directory
cd $HOME

# Find the Node.js executable path
NODE_PATH=$(which node)

# Check if the node command is found, if not, exit the script
if [ -z "$NODE_PATH" ]; then
    echo "Node.js not found. Please install Node.js to continue."
    exit 1
fi

# Check if starkli is installed by checking its version
if ! starkli --version &> /dev/null; then
    echo "starkli not found. Installing..."
    curl https://get.starkli.sh | sh
    # Source the Starkli environment variables
    . /root/.starkli/env
    # Update Starkli to the latest version
    starkliup
    # Set the STARKNET_RPC environment variable
    export STARKNET_RPC="http://localhost:9944/"
else
    echo "starkli found. Proceeding with existing setup..."
fi

# Define project directory
PROJECT_DIR="$HOME/madara-get-started"

# Check if the madara-get-started folder exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "madara-get-started directory not found. Cloning repository..."
    git clone https://github.com/karnotxyz/madara-get-started "$PROJECT_DIR"
else
    echo "madara-get-started directory already exists. Skipping cloning..."
fi

# Navigate to the project directory
cd "$PROJECT_DIR"

# Install dependencies
echo "Installing dependencies..."
npm install

# Show HCA logo
echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

# Run the first command using the Node.js path
echo "Running declare script..."
declare_output=$($NODE_PATH scripts/declare.js ./contracts/OpenZeppelinAccountCairoOne.sierra.json ./contracts/OpenZeppelinAccountCairoOne.casm.json)

# Check if declare was successful before proceeding
if [ $? -eq 0 ]; then
    echo "Declare command successful. Proceeding to deploy..."
    deploy_output=$($NODE_PATH scripts/deploy.js ./contracts/OpenZeppelinAccountCairoOne.sierra.json 0x1)

    # Extract transaction_hash from the deploy command's output
    transaction_hash=$(echo "$deploy_output" | sed -n 's/.*transaction_hash: '\''\([^'\'']*\)'\''.*/\1/p')

    # Use the extracted transaction_hash in the next command
    if [ ! -z "$transaction_hash" ]; then
        echo "Deploy command successful. Transaction hash: $transaction_hash"
        
        # $($NODE_PATH scripts/get_transaction.js $transaction_hash)
    else
        echo "Failed to extract transaction hash."
    fi
else
    echo "Declare command failed. Exiting..."
fi
