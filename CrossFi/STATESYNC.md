### STATE SYNC PROCEDURE

1. Halt the Node
```
sudo systemctl stop crossfid
```

2. Reset Configuration (Retain Address Book)
```
crossfid tendermint unsafe-reset-all --home ~/.mineplex-chain/ --keep-addr-book
```

3. Define and Configure Configuration Files
```bash
SNAP_RPC="http://crossfi-test-rpc.ramadhvni.com:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.mineplex-chain/config/config.toml

more ~/.mineplex-chain/config/config.toml | grep 'rpc_servers'

more ~/.mineplex-chain/config/config.toml | grep 'trust_height'

more ~/.mineplex-chain/config/config.toml | grep 'trust_hash'
```

4. Restart the Node
```
sudo systemctl restart crossfid
```

5. Monitor Logs and Await Synchronization (in minutes)
```
sudo journalctl -u crossfid -f --no-hostname -o cat
```

This guide outlines the steps to sync your node's state. Follow each step carefully for a successful synchronization process.