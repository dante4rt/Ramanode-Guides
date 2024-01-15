#!/bin/bash

read -p "Enter your Git email: " git_email
read -p "Enter your Git name: " git_name

git config --global user.email "$git_email"
git config --global user.name "$git_name"

curl -L https://foundry.paradigm.xyz | bash

export PATH="$HOME/.foundry/bin:$PATH"

foundryup

forge init hello_foundry --force
cd hello_foundry

forge install foundry-rs/forge-std --no-commit

read -p "Please enter your private key: " PRIVATE_KEY
forge create src/Counter.sol:Counter \
  --rpc-url https://rpc.katla.taiko.xyz \
  --private-key "$PRIVATE_KEY"

echo "Deployment complete!"
echo "Subscribe our channel -> https://t.me/HappyCuanAirdrop"
