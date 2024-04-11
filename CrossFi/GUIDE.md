# Deploying a Crossfi Testnet Node: A Comprehensive Guide

## 1. System Requirements

**Official Requirements:**

- 4 CPUs
- 8 GB RAM
- 200 GB SSD

**Recommended Setup:**

- Utilize SSH terminal like [MobaXTerm](https://mobaxterm.mobatek.net/download.html) for ease of use.

## 2. User Creation

```
sudo adduser crossfi
sudo usermod -aG sudo crossfi
sudo usermod -aG systemd-journal crossfi
sudo su - crossfi
```

## 3. Server Preparation

```
sudo apt update && sudo apt upgrade -y
```

```
sudo apt install make clang pkg-config libssl-dev libclang-dev build-essential git curl ntp jq llvm tmux htop screen unzip cmake snapd lz4 -y
```

```
CHAIN_ID=crossfi-evm-testnet-1
export FOLDER=.mineplex-chain
export MONIKER=YOUR_NODE_NAME_HERE
echo "export MONIKER=${MONIKER}" >> $HOME/.bash_profile
echo "export CHAIN_ID=${CHAIN_ID}" >> $HOME/.bash_profile
echo "export FOLDER=${FOLDER}" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## 4. Node Installation

```
wget https://github.com/crossfichain/crossfi-node/releases/download/v0.3.0-prebuild3/crossfi-node_0.3.0-prebuild3_linux_amd64.tar.gz && tar -xf crossfi-node_0.3.0-prebuild3_linux_amd64.tar.gz
```

```
sudo cp bin/crossfid /usr/bin/
sudo chmod +x /usr/bin/crossfid
git clone https://github.com/crossfichain/testnet.git
```

Replace `<moniker-name>` with your desired name:

```
crossfid init <moniker-name> --chain-id=$CHAIN_ID
```

## 5. Node Configuration

```
# Define peers for your node
PEERS="peer1_address@peer1_ip:port,peer2_address@peer2_ip:port,..."

# Update configuration files
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$FOLDER/config/config.toml
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$FOLDER/config/config.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/$FOLDER/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/$FOLDER/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/$FOLDER/config/config.toml
sed -i 's|indexer =.*|indexer = "'null'"|g' $HOME/$FOLDER/config/config.toml
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
  $HOME/$FOLDER/config/app.toml
```

## 6. Download Latest Snapshot
Fetch the latest snapshot from [Itrocket validator](https://itrocket.net/services/testnet/crossfi/):
```

cp $HOME/$FOLDER/data/priv_validator_state.json $HOME/$FOLDER/priv_validator_state.json.backup
rm -rf $HOME/$FOLDER/data $HOME/$FOLDER/wasmPath
curl https://testnet-files.itrocket.net/crossfi/snap_crossfi.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/$FOLDER
mv $HOME/$FOLDER/priv_validator_state.json.backup $HOME/$FOLDER/data/priv_validator_state.json

```

## 7. Start the Node
```

sudo systemctl daemon-reload
sudo systemctl start crossfid
sudo systemctl enable crossfid
sudo journalctl -u crossfid -f -n 100

```
To check the synchronization status, use the command:
```

crossfid status 2>&1 | jq .SyncInfo

```
- If the output is `true`, synchronization is in progress.
- If the output is `false`, synchronization is complete, and you can proceed to create the validator.

## 8. Wallet Creation
Generate a wallet address and mnemonic phrase:
```

crossfid keys add wallet

```
To recover your wallet:
```

crossfid keys add wallet --recover

```

## 9. Validator Creation
```

crossfid tx staking create-validator \
 --amount=999600000000000000mpx \
 --pubkey=$(crossfid tendermint show-validator) \
 --moniker="$MONIKER" \
 --identity "" \
 --website "" \
 --details "" \
 --chain-id=$CHAIN_ID \
 --commission-rate="0.10" \
 --commission-max-rate="0.20" \
 --commission-max-change-rate="0.01" \
 --min-self-delegation="1000000" \
 --gas="auto" \
 --gas-prices="10000000000000mpx" \
 --gas-adjustment=1.5 \
 --from=wallet

```
Check your validator's status in the [Block Explorer](https://testnet.itrocket.net/crossfi/uptime) under Active or Inactive set.

## 10. Node Backup
After creating the validator, ensure to backup `priv_validator_key.json` located in `.mineplex-chain/config`.

## 11. Node Removal
```

sudo systemctl stop crossfid && \
sudo systemctl disable crossfid && \
rm /etc/systemd/system/crossfid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf uptick && \
rm -rf $FOLDER && \
rm -rf $(which crossfid)

```

### Additional Information:
- Visit the [Crossfi Website](https://crossfi.org/) for more information.
- Refer to the [Official Guide](https://github.com/crossfichain/testnet) for detailed instructions.