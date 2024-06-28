#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Welcome to the Initia Node Setup Script"

read -p "Do you want to create a new wallet or recover an existing one? (new/recover): " OPTION

if [ "$OPTION" == "new" ]; then
    read -p "Enter the name for your new wallet: " WALLET_NAME
    initiad keys add $WALLET_NAME

elif [ "$OPTION" == "recover" ]; then
    read -p "Enter the name for your existing wallet: " WALLET_NAME
    initiad keys add $WALLET_NAME --recover

else
    echo "Invalid option. Please choose 'new' or 'recover'."
    exit 1
fi

WALLET_INFO=$(initiad keys show $WALLET_NAME -a)
ADDRESS=$(echo "$WALLET_INFO" | grep Address | awk '{print $2}')
PUBKEY=$(echo "$WALLET_INFO" | grep pubkey | awk '{print $2}')

echo "Wallet Information:"
echo "Address: $ADDRESS"
echo "Name: $WALLET_NAME"
echo "Pubkey: $PUBKEY"
echo "Type: local"

read -p "Enter your moniker name: " MONIKER_NAME
read -p "Enter your Keybase ID: " KEYBASE_ID
read -p "Enter your validator details: " VALIDATOR_DETAILS
read -p "Enter your website URL: " WEBSITE_URL

initiad tx mstaking create-validator \
--amount 1000000uinit \
--pubkey $(initiad tendermint show-validator) \
--moniker "$MONIKER_NAME" \
--identity "$KEYBASE_ID" \
--details "$VALIDATOR_DETAILS" \
--website "$WEBSITE_URL" \
--chain-id initiation-1 \
--commission-rate 0.05 \
--commission-max-rate 0.20 \
--commission-max-change-rate 0.05 \
--from $WALLET_NAME \
--gas-adjustment 1.4 \
--gas auto \
--gas-prices 0.15uinit \
-y

echo "Setup completed successfully."
