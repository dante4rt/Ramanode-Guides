#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

curl https://sh.rustup.rs -sSf | sh 
. "$HOME/.cargo/env"

sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"
export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

solana-keygen new 

echo "Your Solana wallet address (public key):"
pubkey=$(solana-keygen pubkey)
echo "$pubkey"
echo "Please deposit at least 0.101 SOL to this address."

read -p "Once you have deposited the SOL, press 'y' and then ENTER to continue: " confirm_deposit
if [ "$confirm_deposit" != "y" ]; then
    echo "Please deposit at least 0.101 SOL to the address and then run the script again."
    exit 1
fi

sudo apt-get install -y build-essential gcc

cargo install ore-cli

read -p "Please enter the RPC URL: " rpc_url

read -p "Please enter the fee (default is 1000): " fee
fee=${fee:-1000}

read -p "Please enter the number of threads (default is 4): " threads
threads=${threads:-4}

cat <<EOF > ore.sh
#!/bin/bash

while true 
do 
  echo "Running" 
  ore --rpc "$rpc_url" --keypair ~/.config/solana/id.json --priority-fee $fee mine --threads $threads
  echo "Exited" 
done 
EOF

chmod +x ore.sh

./ore.sh

echo "Mining process started. Check ore.sh for details."
