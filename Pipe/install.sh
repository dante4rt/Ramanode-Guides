#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

cd $HOME

echo "Welcome to the PoP Node installation script by Happy Cuan Airdrop!"

read -p "Please enter the PIPE download URL (from email): " PIPE_URL
read -p "Please enter the DCDND download URL (from email): " DCDND_URL

echo "Configuring firewall rules..."
sudo ufw allow 8002/tcp
sudo ufw allow 8003/tcp
sudo ufw reload
echo "Firewall rules configured successfully!"

echo "Installing prerequisites..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl tar wget aria2 clang pkg-config libssl-dev jq build-essential
echo "Prerequisites installed successfully!"

echo "Creating a screen session..."
screen -S Pipe -d -m

echo "Setting up PoP Node..."
sudo mkdir -p /opt/dcdn

echo "Downloading Pipe tool binary..."
sudo curl -L "$PIPE_URL" -o /opt/dcdn/pipe-tool

echo "Downloading Node binary..."
sudo curl -L "$DCDND_URL" -o /opt/dcdn/dcdnd

echo "Making binaries executable..."
sudo chmod +x /opt/dcdn/pipe-tool
sudo chmod +x /opt/dcdn/dcdnd

echo "Setting up DCDN Node systemd service..."
sudo cat > /etc/systemd/system/dcdnd.service << 'EOF'
[Unit]
Description=DCDN Node Service
After=network.target
Wants=network-online.target

[Service]
ExecStart=/opt/dcdn/dcdnd \
                --grpc-server-url=0.0.0.0:8002 \
                --http-server-url=0.0.0.0:8003 \
                --node-registry-url="https://rpc.pipedev.network" \
                --cache-max-capacity-mb=1024 \
                --credentials-dir=/root/.permissionless \
                --allow-origin=*

Restart=always
RestartSec=5

LimitNOFILE=65536
LimitNPROC=4096

StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node

WorkingDirectory=/opt/dcdn

[Install]
WantedBy=multi-user.target
EOF
echo "Systemd service setup completed!"

echo "Log in to generate access token..."
/opt/dcdn/pipe-tool login --node-registry-url="https://rpc.pipedev.network"

echo "Please scan the QR code displayed and register with the email you've been registered as a Node. Press Enter to continue after completing this step."
read -p ""

echo "Generating registration token..."
/opt/dcdn/pipe-tool generate-registration-token --node-registry-url="https://rpc.pipedev.network"
echo "Registration token saved in /root/.permissionless/registration_token.json"

echo "Starting PoP Node..."
sudo systemctl daemon-reload
sudo systemctl enable dcdnd
sudo systemctl start dcdnd
echo "PoP Node started successfully!"

cat << 'EOF'

=========================================
🎉 Installation Complete! 🎉

Here are some important notes:

➡ To check if your node is running:
/opt/dcdn/pipe-tool list-nodes --node-registry-url="https://rpc.pipedev.network/"

➡ To generate your wallet phrase/mnemonic:
/opt/dcdn/pipe-tool generate-wallet --node-registry-url="https://rpc.pipedev.network"

➡ To link your wallet:
/opt/dcdn/pipe-tool link-wallet --node-registry-url="https://rpc.pipedev.network"
=========================================

EOF
