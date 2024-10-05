#!/bin/bash

wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 4

echo "Setting up BrinX AI Worker Node..."

echo "Setting up the firewall..."
sudo apt update && sudot apt upgrade -y
sudo apt-get install -y ufw
sudo ufw allow ssh
sudo ufw allow 5011/tcp
sudo ufw enable
sudo ufw status

echo "Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

echo "Pulling BrinX AI Worker Node Docker image..."
docker pull admier/brinxai_nodes-worker:latest

echo "Cloning BrinX AI Worker Nodes repository..."
git clone https://github.com/admier1/BrinxAI-Worker-Nodes
cd BrinxAI-Worker-Nodes || exit
chmod +x install_ubuntu.sh
./install_ubuntu.sh
cd ..

echo "Setting up BrinX AI Relay Node..."

echo "Setting up the firewall for Relay Node..."
sudo apt-get install -y ufw
sudo ufw allow ssh
sudo ufw allow 1194/udp
sudo ufw enable
sudo ufw status

echo "Checking CPU architecture..."
CPU_ARCH=$(uname -m)
if [[ "$CPU_ARCH" == "x86_64" ]]; then
    echo "Architecture: AMD64"
    RELAY_COMMAND="sudo docker run -d --name brinxai_relay --cap-add=NET_ADMIN admier/brinxai_nodes-relay:latest"
elif [[ "$CPU_ARCH" == "aarch64" || "$CPU_ARCH" == "arm64" ]]; then
    echo "Architecture: ARM64"
    RELAY_COMMAND="sudo docker run -d --name brinxai_relay --cap-add=NET_ADMIN admier/brinxai_nodes-relay:arm64"
else
    echo "Unsupported architecture: $CPU_ARCH"
    exit 1
fi

echo "Pulling BrinX AI Relay Docker image..."
docker pull admier/brinxai_nodes-relay:latest

echo "Running Relay Node..."
eval $RELAY_COMMAND

echo "Setup completed successfully!"
echo "Follow the instructions to register your Worker and Relay Nodes at https://workers.brinxai.com/"
echo "Subscribe us at https://t.me/HappyCuanAirdrop"