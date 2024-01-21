# Owshen Wallet Manager

## Overview
The "Owshen Wallet Manager" is a Bash script designed to automate the setup and management of the Owshen Wallet on Linux systems. This script handles the installation of necessary dependencies, downloading and setting up the Owshen Wallet AppImage, and managing the wallet initialization with mnemonic phrases.

## Features
- Automatic installation of `libfuse2`, `nodejs`, and `snarkjs`.
- Downloads and sets up the latest version of the Owshen Wallet.
- Securely prompts the user for the 12-word mnemonic phrase for wallet initialization.
- Provides an option to reinitialize the wallet, if it is already set up.
- Integrates visual elements such as a loading animation and a custom logo display.

## Prerequisites
- A Linux-based operating system with `wget`, `curl`, and `sudo` privileges.
- Internet connection for downloading packages and the wallet AppImage.
- Git installed if you want to clone the repository (optional).
- 
## Security Note
When entering your 12-word mnemonic phrase, ensure that you are in a secure environment. This script does not store your mnemonic phrase, but it's crucial to be cautious with such sensitive information.