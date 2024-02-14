#!/bin/bash

# Change to the user's home directory
cd $HOME

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

# Run the first command
echo "Running declare script..."
declare_output=$(node scripts/declare.js ./contracts/OpenZeppelinAccountCairoOne.sierra.json ./contracts/OpenZeppelinAccountCairoOne.casm.json)

# Check if declare was successful before proceeding
if [ $? -eq 0 ]; then
    echo "Declare command successful. Proceeding to deploy..."
    deploy_output=$(node scripts/deploy.js ./contracts/OpenZeppelinAccountCairoOne.sierra.json 0x1)

    # Extract transaction_hash from the deploy command's output
    # Simplified extraction using sed for broader compatibility
    transaction_hash=$(echo "$deploy_output" | sed -n 's/.*transaction_hash: '\''\([^'\'']*\)'\''.*/\1/p')

    # Use the extracted transaction_hash in the next command
    if [ ! -z "$transaction_hash" ]; then
        echo "Deploy command successful. Transaction hash: $transaction_hash"
        node scripts/get_transaction.js $transaction_hash
    else
        echo "Failed to extract transaction hash."
    fi
else
    echo "Declare command failed. Exiting..."
fi
