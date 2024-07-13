#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

WORKDIR=$(pwd)

echo -e "\033[1;34mCreating folder 'hca'...\033[0m"
mkdir -p $WORKDIR/hca && cd $WORKDIR/hca || { echo "Failed to create or navigate to 'hca' folder"; exit 1; }
echo

echo -e "\033[1;34mCreating 'app.html' file...\033[0m"
cat <<EOL > app.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web3 Data Fetcher</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f4f4f9;
            color: #333;
        }
        #content {
            margin-bottom: 20px;
            font-size: 1.5em;
        }
        img {
            max-width: 100%;
            height: auto;
            border-radius: 10px;
        }
    </style>
    <script>
        async function fetchData() {
            const url = 'web3://0xf14e64285Db115D3711cC5320B37264708A47f89:11155111/greeting';
            const response = await fetch(url);
            const data = await response.text();
            document.getElementById('content').textContent = data;
        }
        window.onload = fetchData;
    </script>
</head>
<body>
    <div id="content">Loading greeting...</div>
    <img src="https://i.ibb.co.com/nsY5vrJ/photo-2024-07-13-11-25-11.jpg" alt="Happy Cuan Anime">
</body>
</html>
EOL

echo -e "\033[1;34mFolder 'hca' and file 'app.html' created successfully.\033[0m"
echo

read -sp 'Enter your private key: ' PRIVATE_KEY
echo

read -p 'Enter your EVM wallet address: ' EVM_WALLET_ADDRESS
echo

echo -e "\033[1;34mInstalling ethfs-cli...\033[0m"
npm install -g ethfs-cli || { echo "Failed to install ethfs-cli"; exit 1; }

echo -e "\033[1;34mInstalling eth-blob-uploader...\033[0m"
npm install -g eth-blob-uploader || { echo "Failed to install eth-blob-uploader"; exit 1; }

echo -e "\033[1;34mCreating a filesystem with ethfs-cli...\033[0m"
echo -e "\033[1;35mCOPY THIS DIRECTORY ADDRESS AND SAVE IT SOMEWHERE\033[0m"
ethfs-cli create -p "$PRIVATE_KEY" -c 11155111 || { echo "Failed to create filesystem with ethfs-cli"; exit 1; }
echo

read -p 'Enter the flat directory address: ' FLAT_DIR_ADDRESS
echo

echo -e "\033[1;34mChecking if 'hca' folder exists...\033[0m"
if [ ! -d "$WORKDIR/hca" ]; then
  echo "'hca' folder does not exist in $WORKDIR"
  exit 1
fi

echo -e "\033[1;34mUploading 'hca' folder with ethfs-cli...\033[0m"
ethfs-cli upload -f "$WORKDIR/hca" -a "$FLAT_DIR_ADDRESS" -c 11155111 -p "$PRIVATE_KEY" -t 2 || { echo "Failed to upload folder with ethfs-cli"; exit 1; }
echo

echo -e "\033[1;34mUploading 'app.html' with eth-blob-uploader...\033[0m"
eth-blob-uploader -r http://88.99.30.186:8545 -p "$PRIVATE_KEY" -f "$WORKDIR/hca/app.html" -t "$EVM_WALLET_ADDRESS" || { echo "Failed to upload app.html with eth-blob-uploader"; exit 1; }
echo

echo -e "\033[1;34mCreating a new filesystem again with ethfs-cli...\033[0m"
echo -e "\033[1;35mCOPY THIS DIRECTORY ADDRESS AND SAVE IT SOMEWHERE\033[0m"
ethfs-cli create -p "$PRIVATE_KEY" -c 11155111 || { echo "Failed to create filesystem with ethfs-cli"; exit 1; }
echo

read -p 'Enter the flat directory address: ' FLAT_DIR_ADDRESS2
echo

echo -e "\033[1;34mChecking if 'hca' folder exists again...\033[0m"
if [ ! -d "$WORKDIR/hca" ]; then
  echo "'hca' folder does not exist in $WORKDIR"
  exit 1
fi

echo -e "\033[1;34mUploading 'hca' folder again with ethfs-cli...\033[0m"
echo -e "\033[1;31mThis transaction may get stuck. You should wait 2 minutes. If it is still the same, start the script from the beginning\033[0m"
ethfs-cli upload -f "$WORKDIR/hca" -a "$FLAT_DIR_ADDRESS2" -c 11155111 -p "$PRIVATE_KEY" -t 2 || { echo "Failed to upload folder with ethfs-cli"; exit 1; }
echo

echo -e "\033[1;32mThis is your application’s web3 link:\033[0m https://"$FLAT_DIR_ADDRESS2".3333.w3link.io/app.html"
echo

echo -e "\033[1;32mAll tasks completed successfully.\033[0m"
echo -e "\033[1;32mSubscribe: https://t.me/HappyCuanAirdrop.\033[0m"
echo
