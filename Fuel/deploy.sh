#!/bin/bash

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

show_path_instructions() {
  print_color "cyan" "The Fuel toolchain is installed and up to date"
  print_color "cyan" "fuelup 0.25.0 has been installed in /root/.fuelup/bin. To fetch the latest toolchain containing the forc and fuel-core binaries, run 'fuelup toolchain install latest'. To generate completions for your shell, run 'fuelup completions --shell=SHELL'."
  print_color "yellow" "You might have to add /root/.fuelup/bin to PATH:"
  print_color "yellow" "bash/zsh:"
  print_color "yellow" 'export PATH="${HOME}/.fuelup/bin:${PATH}"'
  print_color "yellow" "fish:"
  print_color "yellow" "fish_add_path ~/.fuelup/bin"
}

set -e
cd $HOME
rm -rf fuel-project

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

export PATH="$HOME/.fuelup/bin:$PATH"

fuelup toolchain install latest
fuelup self update
fuelup update && fuelup default latest
print_color "green" "Fuel Toolchain installed successfully!"

if ! command -v forc &> /dev/null; then
  print_color "red" "Fuel toolchain path not found in PATH variable."
  show_path_instructions
  exit 1
fi

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

print_color "green" "Contract deployed successfully!"

print_color "cyan" "You can explore the contract on FUEL Explorer: https://app.fuel.network/"
