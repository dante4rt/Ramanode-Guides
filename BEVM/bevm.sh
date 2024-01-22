#!/bin/bash

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker on your VPS..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
else
    echo "Docker is already installed."
fi

echo "Enabling ports 30333 and 30334..."
sudo ufw allow 30333/tcp
sudo ufw allow 30334/tcp
sudo ufw --force enable

echo "Creating a host mapping path..."
dataPath="/var/lib/node_bevm_test_storage"
mkdir -p "$dataPath"

echo "Fetching the Docker image..."
sudo docker pull btclayer2/bevm:v0.1.1

read -p "Enter your node name: " nodeName

echo "Running a Docker container..."
containerName="$nodeName-bevm"
sudo docker run -d -p 30333:30333 -v "$dataPath:/root/.local/share/bevm" --name "$containerName" btclayer2/bevm:v0.1.1 bevm \
  "--chain=testnet" \
  "--name=$nodeName" \
  "--pruning=archive" \
  --telemetry-url "wss://telemetry.bevm.io/submit 0"

echo "Docker container '$containerName' started."
echo "Subscribe to our channel -> https://t.me/HappyCuanAirdrop"

echo "Tailing logs of Docker container '$containerName':"
sudo docker logs -f "$containerName"