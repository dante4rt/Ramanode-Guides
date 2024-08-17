#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Choose an option:"
echo "1. Install Symphony Node"
echo "2. Create Validator"
echo "3. Delegate"
echo "4. Remove Node"
read -p "Enter your choice (1, 2, 3, or 4): " choice

if [ "$choice" -eq 1 ]; then
  read -p "Enter your validator name: " MONIKER

  echo "Installing dependencies..."
  sudo apt -q update
  sudo apt -qy install curl git jq lz4 build-essential screen
  sudo apt -qy upgrade

  echo "Configuring Moniker..."
  export MONIKER="$MONIKER"

  if command -v go &> /dev/null; then
    echo "Go is already installed, skipping installation."
  else
    echo "Installing Go..."
    sudo rm -rf /usr/local/go
    curl -Ls https://go.dev/dl/go1.21.11.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
    sudo tee /etc/profile.d/golang.sh > /dev/null << 'EOF'
    export PATH=$PATH:/usr/local/go/bin
EOF
    echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile
    source /etc/profile.d/golang.sh
    source $HOME/.profile
    echo "Go installation completed."
  fi

  echo "Downloading and building binaries..."
  cd $HOME
  rm -rf symphony
  git clone https://github.com/Orchestra-Labs/symphony
  cd symphony
  git checkout v0.3.0
  make build
  mkdir -p $HOME/.symphonyd/cosmovisor/genesis/bin
  mv build/symphonyd $HOME/.symphonyd/cosmovisor/genesis/bin/
  rm -rf build
  sudo ln -s $HOME/.symphonyd/cosmovisor/genesis $HOME/.symphonyd/cosmovisor/current -f
  sudo ln -s $HOME/.symphonyd/cosmovisor/current/bin/symphonyd /usr/local/bin/symphonyd -f

  echo "Installing Cosmovisor and creating daemon service..."
  go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0

  sudo tee /etc/systemd/system/symphony.service > /dev/null << EOF
[Unit]
Description=symphony node service
After=network-online.target
 
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.symphonyd"
Environment="DAEMON_NAME=symphonyd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.symphonyd/cosmovisor/current/bin"
 
[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable symphony.service

  echo "Initializing the node..."
  symphonyd config chain-id symphony-testnet-3
  symphonyd config keyring-backend test
  symphonyd init $MONIKER --chain-id symphony-testnet-3
  wget -O $HOME/.symphonyd/config/addrbook.json https://files.ramanode.top/testnet/symphony/addrbook.json
  wget -O $HOME/.symphonyd/config/genesis.json https://files.ramanode.top/testnet/symphony/genesis.json
  PEERS="$(curl -sS https://symphony-testnet-rpc.ramanode.top/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
  sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.symphonyd/config/config.toml
  sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0note\"|" $HOME/.symphonyd/config/app.toml
  sed -i \
    -e 's|^pruning *=.*|pruning = "custom"|' \
    -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
    -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
    -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
    $HOME/.symphonyd/config/app.toml

  echo "Starting service and checking node logs..."
  screen -S symphony -dm
  screen -S symphony -p 0 -X stuff 'sudo systemctl start symphony.service && sudo journalctl -u symphony.service -f --no-hostname -o cat\n'

  echo "Installation is complete!"
  echo "Check your logs with: screen -r symphony"
  echo "Subscribe: https://t.me/HappyCuanAirdrop"

elif [ "$choice" -eq 2 ]; then
  read -p "Enter your validator name: " MONIKER
  read -p "Enter your validator details: " DETAILS
  read -p "Enter your keybase id: " KEYBASE
  read -p "Enter your website: " WEBSITE
  read -p "Enter your email: " EMAIL
  read -p "Enter your wallet name: " WALLET_NAME

  echo "Creating validator..."
  symphonyd tx staking create-validator \
  --amount 10000note \
  --pubkey $(symphonyd tendermint show-validator) \
  --moniker "$MONIKER" \
  --identity "$KEYBASE" \
  --details "$DETAILS" \
  --website "$WEBSITE" \
  --security-contact "$EMAIL" \
  --chain-id symphony-testnet-3 \
  --commission-rate 0.05 \
  --commission-max-rate 0.20 \
  --commission-max-change-rate 0.01 \
  --min-self-delegation 1 \
  --from "$WALLET_NAME" \
  --gas-adjustment 1.4 \
  --gas auto \
  --fees 800note \
  -y

  echo "Validator has been created!"
  echo "Check your validator here: https://testnet.ping.pub/symphony/"
  echo "Subscribe: https://t.me/HappyCuanAirdrop"

elif [ "$choice" -eq 3 ]; then
  read -p "Enter your wallet name: " WALLET_NAME
  read -p "Enter the amount to delegate (e.g., 1000000 for 1 MLD): " AMOUNT

  echo "Delegating..."
  symphonyd tx staking delegate $(symphonyd keys show $WALLET_NAME --bech val -a) ${AMOUNT}note --from $WALLET_NAME --chain-id symphony-testnet-3 --gas auto --gas-adjustment 1.4 --fees 800note -y

  echo "Delegation complete!"
  echo "Subscribe: https://t.me/HappyCuanAirdrop"

elif [ "$choice" -eq 4 ]; then
  echo "Removing Symphony Node..."
  cd $HOME
  sudo systemctl stop symphony
  sudo systemctl disable symphony
  sudo rm /etc/systemd/system/symphony.service
  sudo systemctl daemon-reload
  sudo rm -f $(which symphonyd)
  sudo rm -rf $HOME/.symphonyd
  sudo rm -rf $HOME/symphony

  echo "Symphony Node has been removed."
  echo "Subscribe: https://t.me/HappyCuanAirdrop"

else
  echo "Invalid choice. Please run the script again and choose either 1, 2, 3, or 4."
fi
