#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Starting the AlignedLayer public proof task setup..."

echo "Updating and upgrading the system..."
sudo apt update -y
sudo apt upgrade -y

echo "Installing curl..."
sudo apt-get install curl -y

echo "Downloading and installing ALignedProof..."
curl -L https://raw.githubusercontent.com/yetanotherco/aligned_layer/main/batcher/aligned/install_aligned.sh | bash

echo "Sourcing the .bashrc to update the environment variables..."
source "$HOME/.bashrc"

echo "Downloading an example SP1 proof file with its ELF file..."
curl -L https://raw.githubusercontent.com/yetanotherco/aligned_layer/main/batcher/aligned/get_proof_test_files.sh | bash

echo "Sending proof..."
rm -rf ~/aligned_verification_data/
aligned submit \
--proving_system SP1 \
--proof ~/.aligned/test_files/sp1_fibonacci.proof \
--vm_program ~/.aligned/test_files/sp1_fibonacci-elf \
--aligned_verification_data_path ~/aligned_verification_data \
--conn wss://batcher.alignedlayer.com

echo "Verifying proof on-chain and capturing the log..."
aligned verify-proof-onchain \
--aligned-verification-data ~/aligned_verification_data/*.json \
--rpc https://ethereum-holesky-rpc.publicnode.com \
--chain holesky

echo "Setup complete. Please follow the instructions to tweet and submit proof in Discord."
echo "Join the Discord from the profile: https://linktr.ee/AlignedLayer"

echo "Script execution finished."
