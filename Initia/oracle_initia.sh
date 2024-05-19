#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Installation guide"

echo "1. Install required packages"
sudo apt update && \
sudo apt install curl git jq build-essential gcc unzip wget -y

echo "2. Install Go"
cd $HOME && \
if ! command -v go &> /dev/null; then
    ver="1.22.2" && \
    wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
    sudo rm -rf /usr/local/go && \
    sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
    rm "go$ver.linux-amd64.tar.gz" && \
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
    source $HOME/.bash_profile
else
    echo "Go is already installed. Skipping installation."
fi

echo "3. Install slinky binary"
cd $HOME && \
ver="v0.4.3" && \
git clone https://github.com/skip-mev/slinky.git && \
cd slinky && \
git checkout $ver && \
make build && \
sudo mv build/slinky /usr/local/bin/

echo "4. Set Up Variables"
echo 'export NODE_GRPC_ENDPOINT=$(grep "localhost" $HOME/.initia/config/app.toml | grep -Po "(?<=\"localhost:)[0-9]+")' >> ~/.bash_profile
echo 'export ORACLE_CONFIG_PATH="$HOME/slinky/config/core/oracle.json"' >> ~/.bash_profile
echo 'export ORACLE_GRPC_PORT="8080"' >> ~/.bash_profile
echo 'export ORACLE_METRICS_ENDPOINT="0.0.0.0:8002"' >> ~/.bash_profile
source $HOME/.bash_profile

echo "5. Update oracle configuration"
sed -i "s|\"url\": \".*\"|\"url\": \"$NODE_GRPC_ENDPOINT\"|" $ORACLE_CONFIG_PATH
sed -i "s|\"prometheusServerAddress\": \".*\"|\"prometheusServerAddress\": \"$ORACLE_METRICS_ENDPOINT\"|" $ORACLE_CONFIG_PATH
sed -i "s|\"port\": \".*\"|\"port\": \"$ORACLE_GRPC_PORT\"|" $ORACLE_CONFIG_PATH

echo "6. Create a Service File"
sudo tee /etc/systemd/system/initia-oracle.service > /dev/null <<EOF
[Unit]
Description=Initia Oracle
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which slinky) --oracle-config-path $ORACLE_CONFIG_PATH
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo "7. Start the Oracle"
sudo systemctl daemon-reload && \
sudo systemctl enable initia-oracle && \
sudo systemctl restart initia-oracle

echo "Enable Oracle Vote Extension"
echo 'ORACLE_CLIENT_TIMEOUT="500ms"' >> ~/.bash_profile
echo 'NODE_APP_CONFIG_PATH="$HOME/.initia/config/app.toml"' >> ~/.bash_profile

sed -i '/\[oracle\]/!b;n;c\enabled = "true"' $NODE_APP_CONFIG_PATH
sed -i "/oracle_address =/c\oracle_address = \"$NODE_GRPC_ENDPOINT\"" $NODE_APP_CONFIG_PATH
sed -i "/client_timeout =/c\client_timeout = \"$ORACLE_CLIENT_TIMEOUT\"" $NODE_APP_CONFIG_PATH
sed -i '/metrics_enabled =/c\metrics_enabled = "false"' $NODE_APP_CONFIG_PATH

echo "Oracle setup completed successfully."
