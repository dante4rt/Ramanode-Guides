#!/bin/bash

install_foundry() {
    if ! command -v cast &> /dev/null; then
        echo "Foundry not found. Installing Foundry..."
        curl -L https://foundry.paradigm.xyz | bash
        export PATH="$HOME/.foundry/bin:$PATH"
        
        if [ -f ~/.bashrc ]; then
            source ~/.bashrc
        elif [ -f ~/.zshrc ]; then
            source ~/.zshrc
        else
            echo "No .bashrc or .zshrc file found"
            exit 1
        fi
        
        foundryup
    else
        echo "Foundry is already installed."
    fi
}

if [ ! -f "loader.sh" ]; then
    echo "Showing HCA logo..."
    wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh
    chmod +x loader.sh
else
    echo "loader.sh from HCA already exists. Skipping download."
fi

./loader.sh

install_foundry

KEYS_DIR="$HOME/.aligned_keystore"
BATCHER_ADDR="0x815aeCA64a974297942D2Bbf034ABEe22a38A003"
RPC_URL="https://ethereum-holesky-rpc.publicnode.com"
CHAIN="holesky"

create_keystore() {
    echo "Creating a new keystore using Foundry..."
    mkdir -p $KEYS_DIR
    cast wallet new-mnemonic --words 12 > mnemonic.txt
    cat mnemonic.txt
    read -p "Please save your mnemonic phrase and press Enter to continue..."
    PRIVATE_KEY=$(grep "Private key" mnemonic.txt | awk '{print $3}')
    cast wallet import $KEYS_DIR/keystore0 --interactive <<< "$PRIVATE_KEY"
    echo "Keystore created at $KEYS_DIR/keystore0"
}

fund_batcher() {
    echo "Funding the batcher..."
    read -p "Enter the amount of Ether to fund the batcher (e.g., 0.1ether): " AMOUNT
    aligned deposit-to-batcher \
        --batcher_addr $BATCHER_ADDR \
        --rpc $RPC_URL \
        --chain $CHAIN \
        --keystore_path $KEYS_DIR/keystore0 \
        --amount $AMOUNT
}

send_proof() {
    echo "Sending proof..."
    read -p "Enter the proving system (SP1, Risc0, GnarkPlonkBn254, GnarkPlonkBls12_381, Groth16Bn254): " PROVING_SYSTEM
    read -p "Enter the path to the proof file: " PROOF_FILE
    read -p "Enter the path to the VM program file (or verification key for Gnark systems): " VM_PROGRAM_FILE
    read -p "Enter the path to the public input file (optional, press Enter to skip): " PUBLIC_INPUT_FILE
    read -p "Enter the proof generator address (optional, press Enter to skip): " PROOF_GEN_ADDR
    read -p "Enter the batch inclusion data directory path (optional, press Enter to skip): " BATCH_DATA_DIR

    rm -rf ./aligned_verification_data/

    aligned submit \
        --proving_system $PROVING_SYSTEM \
        --proof $PROOF_FILE \
        --vm_program $VM_PROGRAM_FILE \
        --conn wss://batcher.alignedlayer.com \
        --keystore_path $KEYS_DIR/keystore0 \
        --rpc $RPC_URL \
        --batcher_addr $BATCHER_ADDR \
        ${PUBLIC_INPUT_FILE:+--public_input $PUBLIC_INPUT_FILE} \
        ${PROOF_GEN_ADDR:+--proof_generator_addr $PROOF_GEN_ADDR} \
        ${BATCH_DATA_DIR:+--batch_inclusion_data_directory_path $BATCH_DATA_DIR}

    echo "Proof submitted!"
}

while true; do
    echo "Choose an option:"
    echo "1. Create Keystore"
    echo "2. Fund the Batcher"
    echo "3. Send Proof"
    echo "4. Exit"
    read -p "Enter your choice [1-4]: " CHOICE

    case $CHOICE in
        1)
            create_keystore
            ;;
        2)
            fund_batcher
            ;;
        3)
            send_proof
            ;;
        4)
            echo "Process completed successfully."
            echo "Subscribe: https://t.me/HappyCuanAirdrop"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 4."
            ;;
    esac
done
