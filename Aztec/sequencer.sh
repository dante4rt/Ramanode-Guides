#!/bin/bash

set -e

echo "Showing HCA logo..."
wget -q -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

read -p "Enter your Sepolia RPC URL: " RPC_URL
read -p "Enter your BEACON RPC URL: " BEACON_URL
read -p "Enter your Private Key (0x...): " PRIVATE_KEY
read -p "Enter your Public Address (0x...): " PUBLIC_ADDRESS
IP=$(curl -s ipv4.icanhazip.com)
echo "Detected Public IP: $IP"

echo "Installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev ufw

if ! command -v docker &> /dev/null; then
  echo "Docker not found. Installing Docker..."
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

  sudo apt-get install -y ca-certificates gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo systemctl enable docker
  sudo systemctl restart docker
  sudo docker run hello-world
else
  echo "Docker already installed. Skipping Docker installation."
fi

if ! command -v aztec &> /dev/null; then
  echo "Installing Aztec tools..."
  bash -i <(curl -s https://install.aztec.network)
  echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
else
  echo "Aztec already installed. Skipping installation."
fi

aztec-up alpha-testnet

echo "Configuring firewall..."
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 40400
sudo ufw allow 8080
sudo ufw --force enable

echo "Creating systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/aztec-sequencer.service
[Unit]
Description=Aztec Sequencer Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME
ExecStart=$HOME/.aztec/bin/aztec start --node --archiver --sequencer \\
  --network alpha-testnet \\
  --l1-rpc-urls $RPC_URL \\
  --l1-consensus-host-urls $BEACON_URL \\
  --sequencer.validatorPrivateKey $PRIVATE_KEY \\
  --sequencer.coinbase $PUBLIC_ADDRESS \\
  --p2p.p2pIp $IP \\
  --p2p.maxTxPoolSize 1000000000
Restart=always
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable aztec-sequencer
sudo systemctl start aztec-sequencer

echo ""
echo "✅ Aztec Sequencer is now running!"
echo "🔧 To check logs: sudo journalctl -fu aztec-sequencer"
echo "📢 Subscribe: https://t.me/HappyCuanAirdrop"
