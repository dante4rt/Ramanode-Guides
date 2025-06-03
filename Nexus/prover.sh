#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Setting up Nexus Laboratories Prover..."
echo ""

is_installed() {
  dpkg -l | grep -qw "$1"
}

install_dependencies() {
  echo "Installing dependencies..."
  sudo apt update && sudo apt upgrade -y

  packages=(
    curl
    iptables
    build-essential
    git
    wget
    lz4
    jq
    make
    gcc
    nano
    automake
    autoconf
    tmux
    htop
    nvme-cli
    pkg-config
    libssl-dev
    libleveldb-dev
    tar
    clang
    bsdmainutils
    ncdu
    unzip
  )

  for package in "${packages[@]}"; do
    if is_installed "$package"; then
      echo "$package is already installed. Skipping."
    else
      echo "Installing $package..."
      sudo apt install -y "$package"
    fi
  done

  if ! command -v rustc &>/dev/null; then
    echo "Installing Rust..."
    sudo curl https://sh.rustup.rs -sSf | sh
    source $HOME/.cargo/env
    export PATH="$HOME/.cargo/bin:$PATH"
    rustup update
    echo "Rust version:"
    rustc --version
  else
    echo "Rust is already installed. Skipping."
  fi
}

run_prover() {
  echo "Starting Prover installation..."

  if sudo curl https://cli.nexus.xyz/install.sh | sh; then
    echo "Nexus CLI installed successfully."
  else
    echo "Nexus CLI installation via curl failed. Trying cargo update and reinstall..."

    cd /root/.nexus/network-api/clients/cli &&
      cargo update &&
      sudo curl https://cli.nexus.xyz/install.sh | sh

    if [ $? -eq 0 ]; then
      echo "Nexus CLI successfully installed after cargo update."
    else
      echo "Nexus CLI installation failed again."
      exit 1
    fi
  fi
}

install_dependencies
run_prover

echo "Setup completed successfully!"
echo "Subscribe to us at https://t.me/HappyCuanAirdrop"
