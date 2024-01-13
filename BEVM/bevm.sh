#!/bin/bash

downloadBEVM() {
    local binaryURL="$1"
    local binaryName="$2"

    if [ ! -e "$binaryName" ]; then
        echo "Downloading BEVM binary..."
        wget "$binaryURL"
        if [ $? -ne 0 ]; then
            echo "Failed to download BEVM binary. Exiting."
            exit 1
        fi
        chmod +x "$binaryName"
    fi
}

echo "Choose the BEVM binary version:"
echo "1. x86 (32-bit)"
echo "2. arm64 (64-bit)"
read -p "Enter the number of your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    binaryURL="https://github.com/btclayer2/BEVM/releases/download/testnet-v0.1.1/bevm-v0.1.1-ubuntu20.04"
    binaryName="bevm-v0.1.1-ubuntu20.04"
elif [ "$choice" == "2" ]; then
    binaryURL="https://github.com/btclayer2/BEVM/releases/download/testnet-v0.1.1/bevm-v0.1.1-ubuntu20.04.1-arm64"
    binaryName="bevm-v0.1.1-ubuntu20.04.1-arm64"
else
    echo "Invalid choice. Please select 1 or 2."
    exit 1
fi

downloadBEVM "$binaryURL" "$binaryName"

read -p "Enter your node name: " nodeName

nodeNameLength=${#nodeName}

paddingLength=$(( 48 + nodeNameLength ))

printEquals() {
  local length=$1
  local even=$(( length % 2 == 0 ? length : length + 1 ))
  printf '=%.0s' $(seq 1 $even)
}

echo
printEquals "$paddingLength"; echo
echo -e " ALL SET !!! "
printEquals "$paddingLength"; echo
echo " THANK YOU FOR YOUR SUPPORT "
printEquals "$paddingLength"; echo
echo " Join our TG: https://t.me/HappyCuanAirdrop "
printEquals "$paddingLength"; echo
echo

echo "Running BEVM with node name: $nodeName"
"./$binaryName" --chain=testnet --name="$nodeName" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
