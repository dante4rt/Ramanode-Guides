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

echo "🚀 Installing HyperSpace CLI..."
while true; do
    curl -s https://download.hyper.space/api/install | bash | tee /root/hyperspace_install.log

    if ! grep -q "Failed to parse version from release data." /root/hyperspace_install.log; then
        echo "✅ HyperSpace CLI installed successfully!"
    break
    else
        echo "❌ Installation failed. Retrying in 10 seconds..."
        sleep 5
    fi
done

echo "🚀 Installing AIOS to the path..."
echo 'export PATH=$PATH:$HOME/.aios' >> ~/.bashrc
export PATH=$PATH:$HOME/.aios
source ~/.bashrc

screen -S hyperspace -dm
screen -S hyperspace -p 0 -X stuff $'aios-cli start\n'

sleep 5

echo "Please create a 'hyperspace.pem' file with your private key."
echo "Opening nano editor..."
nano hyperspace.pem

aios-cli hive import-keys ./hyperspace.pem

echo "🔑 Logging into the hive..."
aios-cli hive login

sleep 5

echo "Downloading the required model..."
aios-cli models add hf:second-state/Qwen1.5-1.8B-Chat-GGUF:Qwen1.5-1.8B-Chat-Q4_K_M.gguf

echo "Connecting to the hive and ensuring the model is registered..."
aios-cli hive connect
aios-cli hive select-tier 3

echo "🔍 Checking node status..."
aios-cli status

echo "Setup complete!"