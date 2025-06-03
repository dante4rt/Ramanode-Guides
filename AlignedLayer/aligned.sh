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

if ! ldconfig -p | grep -q libssl.so.3; then
    echo "libssl.so.3 not found. Installing OpenSSL 3.0.0..."
    sudo apt-get install -y build-essential checkinstall zlib1g-dev
    cd /usr/local/src
    sudo wget https://www.openssl.org/source/openssl-3.0.0.tar.gz
    sudo tar -zxf openssl-3.0.0.tar.gz
    cd openssl-3.0.0
    sudo ./config
    sudo make
    sudo make install
    sudo ldconfig
else
    echo "libssl.so.3 found. Skipping OpenSSL installation."
fi

echo "Downloading and installing ALignedProof..."
curl -L https://raw.githubusercontent.com/yetanotherco/aligned_layer/main/batcher/aligned/install_aligned.sh | bash

ALIGNED_BIN_DIR="$HOME/.aligned/bin"

case $SHELL in
*/zsh)
    PROFILE="${ZDOTDIR-"$HOME"}/.zshenv"
    PREF_SHELL=zsh
    ;;
*/bash)
    PROFILE=$HOME/.bashrc
    PREF_SHELL=bash
    ;;
*/fish)
    PROFILE=$HOME/.config/fish/config.fish
    PREF_SHELL=fish
    ;;
*/ash)
    PROFILE=$HOME/.profile
    PREF_SHELL=ash
    ;;
*)
    echo "aligned: could not detect shell, manually add ${ALIGNED_BIN_DIR} to your PATH."
    exit 1
    ;;
esac

if [[ ":$PATH:" != *":${ALIGNED_BIN_DIR}:"* ]]; then
    if [[ "$PREF_SHELL" == "fish" ]]; then
        echo "fish_add_path -a $ALIGNED_BIN_DIR" >>"$PROFILE"
    else
        echo "export PATH=\"\$PATH:$ALIGNED_BIN_DIR\"" >>"$PROFILE"
    fi
fi

echo "Sourcing the profile to update the environment variables..."
source "$PROFILE"

if ! command -v aligned &>/dev/null; then
    echo "aligned: command not found in PATH, trying to source profile directly"
    source "$HOME/.bashrc" || source "$HOME/.zshrc" || source "$HOME/.config/fish/config.fish" || source "$HOME/.profile"
    if ! command -v aligned &>/dev/null; then
        echo "aligned: command still not found in PATH, please check the installation and PATH configuration."
        exit 1
    fi
fi

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
