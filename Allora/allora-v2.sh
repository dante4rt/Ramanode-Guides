#!/bin/bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Checking prerequisites..."

echo "Remove previous setup directories and Docker containers"
rm -rf allora-chain basic-coin-prediction-node

containers=("worker-2-basic-eth-pred" "inference-basic-eth-pred" "head-basic-eth-pred" "worker-basic-eth-pred")

for container in "${containers[@]}"; do
    if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
        echo "Stopping and removing Docker container: $container"
        docker stop "$container" || true
        docker rm "$container" || true
    fi
done

images=("worker-2-basic-eth-pred" "inference-basic-eth-pred" "head-basic-eth-pred" "worker-basic-eth-pred")

for image in "${images[@]}"; do
    if docker images --format '{{.Repository}}' | grep -q "^${image}$"; then
        echo "Removing Docker image: $image"
        docker rmi "$image" || true
    fi
done

if ! command_exists docker || ! command_exists go || ! command_exists python3; then
    echo "Installing prerequisites..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 python3 python3-pip

    if ! command_exists docker; then
        echo "Installing Docker..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo groupadd docker
        sudo usermod -aG docker $USER
    fi

    if ! command_exists docker-compose; then
        echo "Installing Docker Compose..."
        VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
        curl -L "https://github.com/docker/compose/releases/download/${VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi

    if ! command_exists go; then
        echo "Installing Golang..."
        sudo rm -rf /usr/local/go
        curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
        echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
else
    echo "Prerequisites already installed."
fi

echo "Installing Allora CLI..."
git clone https://github.com/allora-network/allora-chain.git
cd allora-chain && make all
allorad version
cd $HOME

echo "Setting up worker..."
git clone https://github.com/allora-network/basic-coin-prediction-node
cd basic-coin-prediction-node

echo "Enter your wallet seed phrase:"
read -p "Address Restore Mnemonic: " addressRestoreMnemonic

cat <<EOF > config.json
{
    "wallet": {
        "addressKeyName": "testkey",
        "addressRestoreMnemonic": "$addressRestoreMnemonic",
        "alloraHomeDir": "",
        "gas": "1000000",
        "gasAdjustment": 1.0,
        "nodeRpc": "https://allora-testnet-rpc.polkachu.com/",
        "maxRetries": 1,
        "delay": 1,
        "submitTx": false
    },
    "worker": [
        {
            "topicId": 1,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 2,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 7,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        }
    ]
}
EOF

echo "Running the worker..."
chmod +x init.config
./init.config
docker-compose up -d --build

echo "Setup complete. You can check your Allora point for 24 hours after finishing."
echo "Subscribe: https://t.me/HappyCuanAirdrop"
