#!/bin/bash

wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh > /dev/null 2>&1
clear

curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

read -p "Enter your Git email: " git_email
read -p "Enter your Git name: " git_name
read -p "Please enter your private key (Use burner wallet): " PRIVATE_KEY

git config --global user.email "$git_email" > /dev/null 2>&1
git config --global user.name "$git_name" > /dev/null 2>&1
$HOME/loader.sh "sleep 3" "..." "Set Github account"

# Download Binaries
curl -L https://foundry.paradigm.xyz > /dev/null 2>&1
export PATH="$HOME/.foundry/bin:$PATH" > /dev/null 2>&1
foundryup > /dev/null 2>&1
$HOME/loader.sh "sleep 5" "..." "Download Binaries"

#init
forge init hello_foundry --force > /dev/null 2>&1
cd hello_foundry > /dev/null 2>&1
forge install foundry-rs/forge-std --no-commit > /dev/null 2>&1
$HOME/loader.sh "sleep 7" "..." "Install & Initialize"


# Deploy Contract
forge create src/Counter.sol:Counter \
  --rpc-url https://rpc.katla.taiko.xyz \
  --private-key "$PRIVATE_KEY" 
  
echo " "
echo " "
echo -e "Check Output Above, it will thrown \e[1;91mError\e[0m or \e[1;92mSucessful Deployment!\e[0m"
echo " "
