#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

prompt() {
    read -p "$1" response
    echo $response
}

execute_and_prompt() {
    echo -e "\n$1"
    eval "$2"
    read -p "Press [Enter] to continue..."
}

cd $HOME

echo "Eclipse Deployment Program"

execute_and_prompt "Updating your dependencies..." "sudo apt update && sudo apt upgrade -y"

if ! command -v rustc &> /dev/null; then
    response=$(prompt "Do you want to install Rust? (Reply 1 to proceed) ")
    if [ "$response" == "1" ]; then
        execute_and_prompt "Installing Rust..." "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        source "$HOME/.cargo/env"
        execute_and_prompt "Checking Rust version..." "rustc --version"
    fi
else
    echo "Rust is already installed. Skipping installation."
fi

if ! command -v solana &> /dev/null; then
    execute_and_prompt "Installing Solana CLI..." 'sh -c "$(curl -sSfL https://release.solana.com/stable/install)"'
    export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
    execute_and_prompt "Checking Solana version..." "solana --version"
else
    echo "Solana CLI is already installed. Skipping installation."
fi

if ! command -v npm &> /dev/null; then
    execute_and_prompt "Installing npm..." "sudo apt-get install -y npm"
    execute_and_prompt "Checking npm version..." "npm --version"
else
    echo "npm is already installed. Skipping installation."
fi

if ! command -v yarn &> /dev/null; then
    execute_and_prompt "Installing Yarn..." "npm install --global yarn"
    execute_and_prompt "Checking Yarn version..." "yarn --version"
else
    echo "Yarn is already installed. Skipping installation."
fi

if ! command -v anchor &> /dev/null; then
    execute_and_prompt "Installing Anchor CLI..." "cargo install --git https://github.com/project-serum/anchor anchor-cli --locked"
    export PATH="$HOME/.cargo/bin:$PATH"
    execute_and_prompt "Checking Anchor version..." "anchor --version"
else
    echo "Anchor CLI is already installed. Skipping installation."
fi

wallet_path=$(prompt "Enter the path to save your Solana wallet (e.g., /path-to-wallet/my-wallet.json): ")
execute_and_prompt "Creating Solana wallet..." "solana-keygen new -o $wallet_path"

execute_and_prompt "Updating Solana configuration..." "solana config set --url https://testnet.dev2.eclipsenetwork.xyz/ && solana config set --keypair $wallet_path"
execute_and_prompt "Checking Solana address..." "solana address"

echo -e "\nImport your BIP39 Passphrase to OKX/BITGET/METAMASK/RABBY so we can get our EVM Address to Claim Sepolia Faucet, Claim Faucet with your Main Address and Send Sepolia ETH to the wallet imported"
echo -e "Use the following faucets:\nhttps://faucet.quicknode.com/ethereum/sepolia\nhttps://faucets.chain.link/\nhttps://www.infura.io/faucet"
read -p "Press [Enter] to continue..."

if [ -d "testnet-deposit" ]; then
    execute_and_prompt "Removing existing testnet-deposit folder..." "rm -rf testnet-deposit"
fi

execute_and_prompt "Cloning Eclipse Bridge Script..." "git clone https://github.com/Eclipse-Laboratories-Inc/testnet-deposit && cd testnet-deposit && npm install"

solana_address=$(prompt "Enter your Solana Address: ")
ethereum_private_key=$(prompt "Enter your Ethereum Private Key: ")
repeat_count=$(prompt "Enter the number of times to repeat the transaction (recommended 4-5): ")
for ((i=1; i<=repeat_count; i++)); do
    execute_and_prompt "Running bridge script (Iteration $i)..." "node deposit.js $solana_address 0x7C9e161ebe55000a3220F972058Fb83273653a6e 3000000 100000 ${ethereum_private_key:2} https://rpc.sepolia.org"
done

execute_and_prompt "Checking Solana balance..." "solana balance"

balance=$(solana balance | awk '{print $1}')
if [ "$balance" == "0" ]; then
    echo "Your Solana balance is 0. Please deposit funds and try again."
    exit 1
fi

execute_and_prompt "Creating token..." "spl-token create-token --enable-metadata -p TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb"

token_address=$(prompt "Enter your Token Address: ")
execute_and_prompt "Creating token account..." "spl-token create-account $token_address"

execute_and_prompt "Minting token..." "spl-token mint $token_address 10000"
execute_and_prompt "Checking token accounts..." "spl-token accounts"

echo -e "\nSubmit feedback at: https://docs.google.com/forms/d/e/1FAIpQLSfJQCFBKHpiy2HVw9lTjCj7k0BqNKnP6G1cd0YdKhaPLWD-AA/viewform?pli=1"
execute_and_prompt "Checking program address..." "solana address"

echo "Program completed."
