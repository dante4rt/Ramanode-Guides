#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

log_error() {
    echo "[ERROR] $1" >&2
}

check_rust() {
    if command -v rustc >/dev/null 2>&1; then
        rust_version=$(rustc --version | awk '{print $2}')
        required_version="1.79.0"
        if [ "$(printf '%s\n' "$required_version" "$rust_version" | sort -V | head -n1)" != "$required_version" ]; then
            log_error "Rust version is lower than 1.79. Installing Rust..."
            install_rust || {
                log_error "Failed to install Rust."
                exit 1
            }
        else
            echo "Rust version $rust_version is already installed."
        fi
    else
        log_error "Rust is not installed. Installing Rust..."
        install_rust || {
            log_error "Failed to install Rust."
            exit 1
        }
    fi
}

install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || return 1
    source $HOME/.cargo/env || return 1
}

fix_broken_packages() {
    sudo apt --fix-broken install -y || return 1
}

update_system() {
    sudo apt update && sudo apt upgrade -y || return 1
}

install_build_tools() {
    sudo apt install -y build-essential clang libc6-dev libcurl4 libssl-dev || return 1
}

install_snarkos() {
    cd $HOME || {
        log_error "Failed to change directory to $HOME."
        exit 1
    }
    git clone --branch mainnet --single-branch https://github.com/AleoNet/snarkOS.git || {
        log_error "Failed to clone snarkOS repository."
        exit 1
    }
    cd snarkOS || {
        log_error "Failed to change directory to snarkOS."
        exit 1
    }
    git checkout tags/testnet-beta || {
        log_error "Failed to checkout testnet-beta tag."
        exit 1
    }

    if [ -f "./build_ubuntu.sh" ]; then
        ./build_ubuntu.sh || {
            log_error "Failed to execute build_ubuntu.sh."
            exit 1
        }
    fi

    cargo install --locked --path . || {
        log_error "Failed to install snarkOS."
        exit 1
    }
}

open_firewall_ports() {
    sudo ufw allow 4130/tcp
    sudo ufw allow 3030/tcp
    sudo ufw enable -y
}

generate_aleo_account() {
    snarkos account new || {
        log_error "Failed to generate Aleo account."
        exit 1
    }
    echo "Save the private key, view key, and address."
}

run_prover() {
    cd $HOME/snarkOS || {
        log_error "Failed to change directory to $HOME/snarkOS."
        exit 1
    }
    ./run-prover.sh --network 1 || {
        log_error "Failed to execute run-prover.sh."
        exit 1
    }
}

check_rust
fix_broken_packages
update_system
install_build_tools
install_snarkos
open_firewall_ports
generate_aleo_account
run_prover

echo "Script execution completed."
