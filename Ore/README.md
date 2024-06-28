# Ore

## Overview

This repository contains a script for setting up and running the Ore mining process. Ore is a cryptocurrency mining tool built for the Solana blockchain. The script automates the setup process and initiates the mining process once configured.

## Prerequisites

Before running the script, ensure that you have the following prerequisites installed:

- [Rust and cargo](https://www.rust-lang.org/tools/install)
- [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools)
- [curl](https://curl.se/)
- [wget](https://www.gnu.org/software/wget/)
- [gcc](https://gcc.gnu.org/)
- [build-essential](https://packages.debian.org/sid/build-essential) (for Debian-based systems)

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/dante4rt/Ore.git
   ```

2. Navigate to the cloned directory:
   ```bash
   cd Ore
   ```

3. Run the setup script:
   ```bash
   ./setup.sh
   ```

4. Follow the prompts to generate a Solana wallet address (public key) and deposit at least 0.101 SOL to the generated address.

5. After depositing SOL, confirm when prompted.

6. Obtain the Solana RPC URL from [Alchemy](https://dashboard.alchemy.com/) (HTTPS API).

7. Enter the RPC URL when prompted.

8. Once configured, the mining process will begin automatically.

9. Check the `ore.sh` file for details on the mining process.

## Disclaimer

Please note that cryptocurrency mining may consume significant computational resources and energy. Ensure that you have considered the environmental impact and cost implications before proceeding with mining activities.
