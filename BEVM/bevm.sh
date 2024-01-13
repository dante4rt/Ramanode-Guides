#!/bin/bash

# Ask the user to choose a file
echo "Choose the BEVM binary version:"
echo "1. x86 (32-bit)"
echo "2. arm64 (64-bit)"
read -p "Enter the number of your choice (1 or 2): " choice

# Check the user's choice
if [ "$choice" == "1" ]; then
    # Download the x86 BEVM binary
    binaryURL="https://github.com/btclayer2/BEVM/releases/download/testnet-v0.1.1/bevm-v0.1.1-ubuntu20.04"
elif [ "$choice" == "2" ]; then
    # Download the arm64 BEVM binary
    binaryURL="https://github.com/btclayer2/BEVM/releases/download/testnet-v0.1.1/bevm-v0.1.1-ubuntu20.04.1-arm64"
else
    echo "Invalid choice. Please select 1 or 2."
    exit 1
fi

# Step 1: Download the selected BEVM binary
echo "Downloading BEVM binary..."
wget "$binaryURL"

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download BEVM binary. Exiting."
    exit 1
fi

# Step 2: Make the binary executable
chmod +x bevm-*

# Ask the user for their node name
read -p "Enter your node name: " nodeName

# Calculate the length of the node name for padding
nodeNameLength=${#nodeName}

# Calculate the padding for consistent "===" lines
paddingLength=$((29 + nodeNameLength))

# Display result and instructions together with consistent "===" lines
echo '==================== ALL SET !!! ===================='
echo '========= THANK YOU FOR YOUR SUPPORT =========='
echo -e "========= Join our TG: https://t.me/HappyCuanAirdrop =========\n"

# Run BEVM with user-provided node name
echo "Running BEVM with node name: $nodeName"
./bevm-* --chain=testnet --name="$nodeName" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
