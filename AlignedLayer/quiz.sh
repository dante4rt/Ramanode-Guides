#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Setting up Aligned Layer – Quiz Campaign..."

RUSTUP_HOME="$HOME/.rustup"
CARGO_HOME="$HOME/.cargo"
FOUNDRY_HOME="$HOME/.foundry"

load_rust() {
    export RUSTUP_HOME="$HOME/.rustup"
    export CARGO_HOME="$HOME/.cargo"
    export PATH="$CARGO_HOME/bin:$PATH:$FOUNDRY_HOME/bin"
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
}

install_dependencies() {
    echo "Installing system dependencies (build tools, OpenSSL, pkg-config)..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y build-essential libssl-dev curl pkg-config
    elif command -v yum &> /dev/null; then
        sudo yum groupinstall 'Development Tools' && sudo yum install -y openssl-devel curl pkg-config
    elif command -v dnf &> /dev/null; then
        sudo dnf groupinstall 'Development Tools' && sudo dnf install -y openssl-devel curl pkg-config
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu base-devel openssl curl pkg-config
    else
        echo "Unsupported package manager. Please install dependencies manually."
        exit 1
    fi
}

install_dependencies

install_rust() {
    echo "Checking Rust installation..."
    if command -v rustup &> /dev/null; then
        echo "Rust is already installed."
        read -p "Do you want to reinstall or update Rust? (y/n): " choice
        if [[ "$choice" == "y" ]]; then
            echo "Reinstalling Rust..."
            rustup self uninstall -y
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        fi
    else
        echo "Rust is not installed. Installing now..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi

    load_rust

    echo "Fixing permissions for Rust directories..."
    chmod -R 755 "$RUSTUP_HOME" "$CARGO_HOME"

    rust_version=$(rustc --version)
    cargo_version=$(cargo --version)
    echo "Rust version: $rust_version"
    echo "Cargo version: $cargo_version"
}

install_foundry() {
    echo "Installing Foundry (forge, cast, anvil)..."
    if [ ! -d "$FOUNDRY_HOME/bin" ]; then
        curl -L https://foundry.paradigm.xyz | bash
    else
        echo "Foundry is already installed."
    fi

    if ! grep -q 'export PATH="$HOME/.foundry/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bashrc
    fi
    if ! grep -q 'export PATH="$HOME/.foundry/bin:$PATH"' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.zshrc
    fi

    if [ "$SHELL" = "/bin/bash" ]; then
        export PATH="$FOUNDRY_HOME/bin:$PATH"
        source ~/.bashrc
    elif [ "$SHELL" = "/bin/zsh" ]; then
        export PATH="$FOUNDRY_HOME/bin:$PATH"
        source ~/.zshrc
    fi

    foundryup
}

install_rust
install_foundry

import_burner_wallet() {
    WALLET_DIR="$HOME/.aligned_keystore"
    if [ -d "$WALLET_DIR" ]; then
        rm -rf "$WALLET_DIR" && echo "Deleted existing directory $WALLET_DIR."
    fi
    mkdir -p "$WALLET_DIR"
    cast wallet import "$WALLET_DIR/keystore0" --interactive
}

clone_aligned_layer() {
    if [ -d aligned_layer ]; then
        rm -rf aligned_layer && echo "Deleted existing aligned_layer directory."
    fi
    git clone https://github.com/yetanotherco/aligned_layer.git && cd aligned_layer/examples/zkquiz
}

run_zk_quiz() {
    make answer_quiz KEYSTORE_PATH="$HOME/.aligned_keystore/keystore0"
}

import_burner_wallet
clone_aligned_layer
run_zk_quiz

echo "Automation complete!"
echo "Subscribe: https://t.me/HappyCuanAirdrop"