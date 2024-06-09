#!/bin/bash

set -e

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

print_color() {
  COLOR=$1
  TEXT=$2
  NC='\033[0m' 
  case $COLOR in
    "red") COLOR='\033[0;31m' ;;
    "green") COLOR='\033[0;32m' ;;
    "yellow") COLOR='\033[0;33m' ;;
    "blue") COLOR='\033[0;34m' ;;
    "cyan") COLOR='\033[0;36m' ;;
    "magenta") COLOR='\033[0;35m' ;;
  esac
  echo -e "${COLOR}${TEXT}${NC}"
}

print_color "cyan" "Updating and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt-get install screen git nano -y


print_color "cyan" "Installing Rust..."
curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup install stable
rustup update stable
rustup default stable
print_color "green" "Rust installed successfully!"

print_color "cyan" "Installing Fuel Toolchain..."
curl https://install.fuel.network | sh -s -- -y

if [ -f /root/.bashrc ]; then
  source /root/.bashrc
elif [ -f /home/runner/.bashrc ]; then
  source /home/runner/.bashrc
elif [ -f $HOME/.bashrc ]; then
  source $HOME/.bashrc
else
  print_color "red" "No .bashrc file found to source."
  exit 1
fi

fuelup toolchain install latest
fuelup self update
fuelup update && fuelup default latest
print_color "green" "Fuel Toolchain installed successfully!"

print_color "cyan" "Creating Fuel project..."
mkdir -p fuel-project && cd fuel-project
forc new counter-contract

print_color "cyan" "Editing the contract..."
cat <<EOF > counter-contract/src/main.sw
contract;

storage {
    counter: u64 = 0,
}

abi Counter {
    #[storage(read, write)]
    fn increment();

    #[storage(read)]
    fn count() -> u64;
}

impl Counter for Contract {
    #[storage(read)]
    fn count() -> u64 {
        storage.counter.read()
    }

    #[storage(read, write)]
    fn increment() {
        let incremented = storage.counter.read() + 1;
        storage.counter.write(incremented);
    }
}
EOF

print_color "cyan" "Building the contract..."
cd counter-contract
forc build
print_color "green" "Contract built successfully!"

print_color "cyan" "Deploying the contract..."
print_color "yellow" "Remember to import your FUEL wallet if not already done."

print_color "cyan" "Importing wallet..."
forc wallet import

print_color "cyan" "Creating new account..."
forc wallet account new

print_color "cyan" "Checking wallet accounts..."
forc wallet accounts

print_color "cyan" "Deploying contract to testnet..."
forc deploy --testnet
print_color "yellow" "Enter '0' as Index and click 'y' to confirm deployment."

print_color "green" "Contract deployed successfully!"

print_color "cyan" "You can explore the contract on FUEL Explorer: https://app.fuel.network/"
