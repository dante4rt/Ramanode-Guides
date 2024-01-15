# Foundry Deployment Script

This script automates the process of deploying a smart contract using Foundry.

## Features

- Sets up Foundry for smart contract deployment.
- Initializes a new Foundry project.
- Handles Git configuration for the user.
- Prompts for the user's private key for contract deployment.

## Prerequisites

- Git must be installed on your system.
- You should have a basic understanding of smart contracts and Foundry.

## Usage

1. Save the script in a file named `deploy.sh`.
2. Make the script executable: `chmod +x deploy.sh`.
3. Run the script: `./deploy.sh`.
4. Enter your Git email and name when prompted.
5. Enter your private key for contract deployment when prompted.

## What the Script Does

1. Asks for your Git email and name to configure Git.
2. Installs Foundry.
3. Updates the PATH environment variable.
4. Initializes a new Foundry project in the `hello_foundry` directory, overwriting if necessary.
5. Installs the `forge-std` library.
6. Prompts for your private key and deploys the smart contract.

## Security Notice

- Ensure you are in a secure environment when entering sensitive information like your private key.
- Avoid running scripts as the root user due to potential security risks.

## Support

For support, join our Telegram channel: [HappyCuanAirdrop](https://t.me/HappyCuanAirdrop)