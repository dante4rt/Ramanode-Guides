#!/bin/bash

if [ ! -f "loader.sh" ]; then
    echo "Showing HCA logo..."
    wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh
    chmod +x loader.sh
    ./loader.sh
else
    echo "loader.sh from HCA already exists. Skipping download."
fi

curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

sudo apt update && sudo apt upgrade -y
sudo apt-get install -y build-essential gcc cargo

cargo install ore-cli

if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    sudo apt update && sudo apt upgrade -y
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
else
    echo "Node.js is already installed."
fi

if ! command -v solana &> /dev/null; then
    echo "Solana CLI not found. Installing Solana CLI..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
    export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
else
    echo "Solana CLI is already installed."
fi

echo "Which wallet do you want to use?"
echo "1. New Wallet"
echo "2. Existing Wallet/Recover"
read -p "Enter your choice (1 or 2): " wallet_choice

if [ "$wallet_choice" == "1" ]; then
    echo "Generating a new Solana wallet..."
    solana-keygen new
elif [ "$wallet_choice" == "2" ]; then
    echo "Recovering an existing Solana wallet..."
    echo "How would you like to recover your wallet?"
    echo "1. Import from mnemonic"
    echo "2. Import from private key"
    read -p "Enter your choice (1 or 2): " import_choice

    if [ "$import_choice" == "1" ]; then
        solana-keygen recover
    elif [ "$import_choice" == "2" ]; then
        read -p "Please enter your private key (base58 encoded): " private_key

        cat <<EOF > import_keypair.js
const fs = require('fs');

const base58Decode = (str) => {
  const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  const base = alphabet.length;
  const bytes = [0];
  for (let char of str) {
    let carry = alphabet.indexOf(char);
    if (carry === -1) throw new Error('Invalid base58 character');
    for (let j = 0; j < bytes.length; ++j) {
      carry += bytes[j] * base;
      bytes[j] = carry % 256;
      carry = (carry / 256) | 0;
    }
    while (carry > 0) {
      bytes.push(carry % 256);
      carry = (carry / 256) | 0;
    }
  }
  for (let char of str) {
    if (char === '1') bytes.push(0);
    else break;
  }
  return new Uint8Array(bytes.reverse());
};

const privateKey = "$private_key";
const decodedKey = base58Decode(privateKey);
fs.writeFileSync("/root/.config/solana/id.json", JSON.stringify(Array.from(decodedKey)));
console.log("Keypair imported successfully.");
EOF

        node import_keypair.js
    else
        echo "Invalid choice. Exiting..."
        exit 1
    fi
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

read -p "Do you want to use your own Solana RPC URL? (y/n): " use_custom_rpc

if [ "$use_custom_rpc" == "y" ]; then
    read -p "Please enter your Solana RPC URL: " custom_rpc_url
    solana config set --url "$custom_rpc_url"
else
    solana config set --url https://api.mainnet-beta.solana.com
fi

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
