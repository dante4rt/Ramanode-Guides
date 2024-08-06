echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"


echo "Which wallet do you want to use?"
echo "1. New Wallet"
echo "2. Existing Wallet/Recover"
read -p "Enter your choice (1 or 2): " wallet

if [ "$wallet" == "1" ]; then
    echo "Generating a new Solana wallet..."
    solana-keygen new
elif [ "$wallet" == "2" ]; then
    echo "Recovering an existing Solana wallet..."
    solana-keygen recover
else
    echo "Invalid choice. Please enter 1 for New Wallet or 2 for Existing Wallet."
    exit 1
fi


echo "Your Solana wallet address (public key):"
pubkey=$(solana-keygen pubkey)
echo "$pubkey"
echo "Please deposit at least 0.101 SOL to this address."

read -p "Once you have deposited the SOL, press 'y' and then ENTER to continue: " confirm_deposit
if [ "$confirm_deposit" != "y" ]; then
    echo "Please deposit at least 0.101 SOL to the address and then run the script again."
    exit 1

fi

solana config set --url https://api.mainnet-beta.solana.com

sudo apt update && sudo apt upgrade -y
sudo apt-get install -y build-essential gcc cargo

cargo install ore-cli

read -p "Please enter the fee (default is 1000): " fee
fee=${fee:-1000}

read -p "Please enter the number of threads (default is 4): " threads
threads=${threads:-4}

cat <<EOF > ore.sh
#!/bin/bash

while true 
do 
  echo "Running" 
  ore mine --priority-fee $fee --threads $threads
  echo "Exited" 
done 
EOF

chmod +x ore.sh

./ore.sh

echo "Mining process started. Check ore.sh for details."
echo "Subscribe: https://t.me/HappyCuanAirdrop"
