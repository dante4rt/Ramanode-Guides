#!/bin/bash

echo "Stopping and disabling Initia Oracle service..."
sudo systemctl stop initia-oracle
sudo systemctl disable initia-oracle
sudo rm /etc/systemd/system/initia-oracle.service
sudo systemctl daemon-reload

echo "Removing slinky binary..."
sudo rm /usr/local/bin/slinky

echo "Removing cloned repositories..."
rm -rf $HOME/slinky

echo "Removing environment variables..."
sed -i '/NODE_GRPC_ENDPOINT/d' ~/.bash_profile
sed -i '/ORACLE_CONFIG_PATH/d' ~/.bash_profile
sed -i '/ORACLE_GRPC_PORT/d' ~/.bash_profile
sed -i '/ORACLE_METRICS_ENDPOINT/d' ~/.bash_profile
sed -i '/ORACLE_GRPC_ENDPOINT/d' ~/.bash_profile
sed -i '/ORACLE_CLIENT_TIMEOUT/d' ~/.bash_profile
sed -i '/NODE_APP_CONFIG_PATH/d' ~/.bash_profile

echo "Reverting oracle configuration changes..."
ORACLE_CONFIG_PATH="$HOME/slinky/config/core/oracle.json"
NODE_APP_CONFIG_PATH="$HOME/.initia/config/app.toml"

if [ -f "$ORACLE_CONFIG_PATH.bak" ]; then
    cp "$ORACLE_CONFIG_PATH.bak" "$ORACLE_CONFIG_PATH"
else
    echo "Backup of oracle.json not found. Manual restoration required."
fi

if [ -f "$NODE_APP_CONFIG_PATH.bak" ]; then
    cp "$NODE_APP_CONFIG_PATH.bak" "$NODE_APP_CONFIG_PATH"
else
    echo "Backup of app.toml not found. Manual restoration required."
fi

echo "Cleaning up Go installation if installed by the script..."
if [ -d "/usr/local/go" ]; then
    sudo rm -rf /usr/local/go
fi

echo "Oracle removal completed successfully."
