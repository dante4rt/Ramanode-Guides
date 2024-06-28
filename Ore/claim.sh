#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

read -p "Enter your RPC URL (default: https://api.mainnet-beta.solana.com/): " YOUR_RPC

YOUR_RPC=${YOUR_RPC:-"https://api.mainnet-beta.solana.com/"}

read -p "Enter your fee (between 1000 - 1000000, default: 10000): " YOUR_FEE

if [[ -z $YOUR_FEE || $YOUR_FEE -lt 1000 || $YOUR_FEE -gt 1000000 ]]; then
  YOUR_FEE=10000
fi

read -p "Enter delay for claim in seconds (default: 60): " DELAY

DELAY=${DELAY:-60}

while true; do
  echo "Running claim with RPC: $YOUR_RPC, Fee: $YOUR_FEE, Delay: $DELAY seconds"
  ore --rpc $YOUR_RPC --keypair ~/.config/solana/id.json --priority-fee $YOUR_FEE claim
  echo "Exited"
  sleep $DELAY
done
