#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

check_node() {
    if ! command -v node &> /dev/null; then
        return 1
    fi
    return 0
}

if ! check_node; then
    echo "Node.js not found. Installing Node.js..."
    apt update && apt upgrade -y
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

echo "Installing rivalz-node-cli..."
npm install -g rivalz-node-cli

cat <<EOL
Before running 'rivalz run', please submit the following details:
1. Your EVM Address
2. The number of CPU cores you want to use for rClient (preferably 50% of your total cores, e.g., if you have 4 cores, use 2 cores)
3. The amount of RAM you want to use for rClient (preferably 60% or 70% of your total RAM)
4. Choose SSD (serial number can be skipped)
5. Disk size (choose 300GB or less)

Have you read the instructions? (y/n)
EOL

read -p "Enter your choice: " choice

while [[ "$choice" != "y" ]]; do
    echo "Please read the instructions again."
    read -p "Have you read the instructions? (y/n): " choice
done

echo "Running 'rivalz run'..."
rivalz run
