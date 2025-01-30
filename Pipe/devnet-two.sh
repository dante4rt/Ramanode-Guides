#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

cd $HOME

echo "Stopping any process using port 8003..."
PID=$(lsof -ti :8003)
if [ -n "$PID" ]; then
  echo "Killing process with PID: $PID"
  kill -9 $PID
else
  echo "No process found using port 8003."
fi

echo "Creating $HOME/pipe-hca folder..."
mkdir -p $HOME/pipe-hca

echo "Downloading pop binary..."
wget -O $HOME/pipe-hca/pop https://dl.pipecdn.app/v0.2.0/pop
chmod +x $HOME/pipe-hca/pop

read -p "Enter the amount of RAM to share (min 4GB): " RAM
if [ "$RAM" -lt 4 ]; then
  echo "RAM must be at least 4GB. Exiting."
  exit 1
fi

read -p "Enter the maximum disk space to use (min 100GB): " DISK
if [ "$DISK" -lt 100 ]; then
  echo "Disk space must be at least 100GB. Exiting."
  exit 1
fi

read -p "Enter your public key: " PUBKEY

SERVICE_FILE="/etc/systemd/system/pipe.service"
echo "Creating $SERVICE_FILE..."

cat <<EOF | sudo tee $SERVICE_FILE > /dev/null
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
User=$USER
ExecStart=$HOME/pipe-hca/pop \
    --ram=$RAM \
    --pubKey $PUBKEY \
    --max-disk $DISK \
    --cache-dir $HOME/pipe-hca/download_cache
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node
WorkingDirectory=$HOME/pipe-hca

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon and starting pipe service..."
sudo systemctl daemon-reload && \
sudo systemctl enable pipe && \
sudo systemctl restart pipe && \
journalctl -u pipe -fo cat