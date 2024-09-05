#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

cd $HOME
sudo apt update && sudo apt upgrade -y 

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt update && sudo apt install -y docker.io
else
    echo "Docker is already installed."
fi
docker --version

sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Enter the RPC username for Bitcoin Core:"
read BTC_RPC_USER
echo "Enter the RPC password for Bitcoin Core:"
read BTC_RPC_PASS

PROJECT_DIR="/root/project/run_btc_testnet4"
mkdir -p $PROJECT_DIR/data
git clone https://github.com/rainbowprotocol-xyz/btc_testnet4
cd btc_testnet4

sed -i "s/-rpcuser=demo/-rpcuser=$BTC_RPC_USER/g" docker-compose.yml
sed -i "s/-rpcpassword=demo/-rpcpassword=$BTC_RPC_PASS/g" docker-compose.yml

docker-compose up -d

echo "Enter a name for your Bitcoin Core wallet:"
read WALLET_NAME

docker exec bitcoind bitcoin-cli -testnet4 -rpcuser=$BTC_RPC_USER -rpcpassword=$BTC_RPC_PASS -rpcport=5000 createwallet $WALLET_NAME
docker exec bitcoind bitcoin-cli -testnet4 -rpcuser=$BTC_RPC_USER -rpcpassword=$BTC_RPC_PASS -rpcport=5000 getnewaddress

cd $HOME

git clone https://github.com/rainbowprotocol-xyz/rbo_indexer_testnet.git
cd rbo_indexer_testnet
wget https://github.com/rainbowprotocol-xyz/rbo_indexer_testnet/releases/download/v0.0.1-alpha/rbo_worker
chmod +x rbo_worker

./rbo_worker worker --rpc http://127.0.0.1:5000 --password $BTC_RPC_PASS --username $BTC_RPC_USER --start_height 42000

echo "Setup is complete!"
echo "Subscribe: https://t.me/HappyCuanAirdrop"
