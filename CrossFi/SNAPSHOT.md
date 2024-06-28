## Snapshot

_Stop Node and Reset Data_
```
sudo systemctl stop crossfi
cp $HOME/.mineplex-chain/data/priv_validator_state.json $HOME/.mineplex-chain/priv_validator_state.json.backup
rm -rf $HOME/.mineplex-chain/data && mkdir -p $HOME/.mineplex-chain/data
```
_Download Snapshot (Automatically Updated Every 24 Hours)_
```
curl -L https://snap.ramadhvni.com/crossfi/latest_snapshot.tar.lz4 | tar -I lz4 -xf - -C $HOME/.mineplex-chain/data
```
```
mv $HOME/.mineplex-chain/priv_validator_state.json.backup $HOME/.mineplex-chain/data/priv_validator_state.json
```
_Restart Node_
```
sudo systemctl restart crossfi && sudo journalctl -u crossfi -f --no-hostname -o cat
```
