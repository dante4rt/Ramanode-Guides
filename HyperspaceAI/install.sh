#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y
cd $HOME
rm -rf $HOME/.cache/hyperspace/models/*
sleep 5

echo "Starting Hyper.Space installation..."

screen -S hyperspace -dm
screen -S hyperspace -p 0 -X stuff $'aios-cli start\n'

sleep 5

echo "Please create a 'hyperspace.pem' file with your private key."
echo "Opening nano editor..."
nano hyperspace.pem

aios-cli hive import-keys ./hyperspace.pem

echo "Selecting the required hive tier..."
aios-cli hive login
aios-cli hive select-tier 5

sleep 5

echo "Downloading the required model..."
aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf

echo "Logging in with the imported keys..."
aios-cli hive login

echo "Connecting to the hive and ensuring the model is registered..."
aios-cli hive connect
aios-cli hive select-tier 5

echo "Setup complete!"