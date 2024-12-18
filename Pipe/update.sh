#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

sudo systemctl stop dcdnd

sudo rm -f /opt/dcdn/pipe-tool /opt/dcdn/dcdnd

read -p "Enter the new PIPE download URL: " PIPE_URL
read -p "Enter the new DCDND download URL: " DCDND_URL

sudo curl -L "$PIPE_URL" -o /opt/dcdn/pipe-tool
sudo curl -L "$DCDND_URL" -o /opt/dcdn/dcdnd

sudo chmod +x /opt/dcdn/pipe-tool
sudo chmod +x /opt/dcdn/dcdnd

sudo systemctl daemon-reload
sudo systemctl enable dcdnd
sudo systemctl restart dcdnd

echo "✅ Update Complete!"
