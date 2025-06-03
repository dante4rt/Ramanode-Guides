#!/bin/bash

wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh
clear

curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

read -p "Enter your Git email: " git_email
read -p "Enter your Git name: " git_name
read -p "Please enter your private key (Use burner wallet): " PRIVATE_KEY

git config --global user.email "$git_email"
git config --global user.name "$git_name"
./loader.sh "sleep 3" "..." "Set Github account"

curl -L https://foundry.paradigm.xyz | bash

export PATH="$HOME/.foundry/bin:$PATH"

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
elif [ -f ~/.zshenv ]; then
    source ~/.zshenv
else
    echo "No .bashrc or .zshenv file found"
    exit 1
fi

foundryup
./loader.sh "sleep 5" "..." "Download Binaries"

forge init hello_foundry --force
cd hello_foundry || {
    echo "Failed to enter directory hello_foundry"
    exit 1
}
forge install foundry-rs/forge-std --no-commit
./loader.sh "sleep 7" "..." "Install & Initialize"

forge create src/Counter.sol:Counter \
    --rpc-url https://rpc.katla.taiko.xyz \
    --private-key "$PRIVATE_KEY"

echo " "
echo " "
echo -e "Check Output Above, it will thrown \e[1;91mError\e[0m or \e[1;92mSucessful Deployment!\e[0m"
echo " "
