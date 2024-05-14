#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

GO_VERSION=$(go version | awk '{print $3}')
if [[ "$GO_VERSION" == *"go1."* ]]; then
    MAJOR_VERSION=$(echo "$GO_VERSION" | cut -d'.' -f2)
    if [ "$MAJOR_VERSION" -lt 19 ]; then
        echo "Go version $GO_VERSION is not supported. Please install Go version 1.19 or above."
        echo "Installing Go version 1.19..."
        wget https://golang.org/dl/go1.19.linux-amd64.tar.gz
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
        export PATH=$PATH:/usr/local/go/bin
    fi
else
    echo "Go version is not detected. Please install Go version 1.19 or above."
    echo "Installing Go version 1.19..."
    wget https://golang.org/dl/go1.19.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
fi

if ! command -v go &> /dev/null; then
    echo "Go is not installed. Exiting..."
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing..."
    sudo apt update
    sudo apt install -y git
fi

if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Installing..."
    sudo apt update
    sudo apt install -y curl
fi

if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing..."
    sudo apt update
    sudo apt install -y jq
fi

cd $HOME
git clone https://github.com/initia-labs/initia
cd initia

git checkout v0.2.11

make install

initiad version --long

read -p "Enter moniker for your node: " moniker

initiad init "$moniker" --chain-id initiation-1

wget https://initia.s3.ap-southeast-1.amazonaws.com/initiation-1/genesis.json

cp genesis.json ~/.initia/config/genesis.json

sed -i -e 's/external_address = \"\"/external_address = \"'$(curl httpbin.org/ip | jq -r .origin)':26656\"/g' ~/.initia/config/config.toml

sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.15uinit,0.01uusdc\"|" ~/.initia/config/app.toml

curl -Ls https://ss-t.initia.nodestake.org/addrbook.json > ~/.initia/config/addrbook.json

sudo tee /etc/systemd/system/initiad.service > /dev/null <<EOF
[Unit]
Description=Initia Daemon

[Service]
Type=simple
User=$(whoami)
ExecStart=$(go env GOPATH)/bin/initiad start
Restart=on-abort
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=initiad
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable initiad
sudo systemctl daemon-reload
sudo systemctl restart initiad

echo "Initia setup completed successfully."
