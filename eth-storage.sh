#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

WORKDIR=$(pwd)

echo -e "\033[1;34mCreating folder 'hca'...\033[0m"
echo
mkdir -p "$WORKDIR/hca" && cd "$WORKDIR/hca" || { echo "Failed to create or navigate to 'hca' folder"; exit 1; }
echo

echo -e "\033[1;34mCreating 'app.html' file...\033[0m"
echo
cat <<EOL > app.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Head or Tail Prediction Game</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(to right, #ff7e5f, #feb47b);
            font-family: 'Roboto', sans-serif;
            color: #fff;
            text-align: center;
        }

        .container {
            background: rgba(0, 0, 0, 0.7);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        h1 {
            margin-bottom: 20px;
        }

        button {
            display: block;
            width: 200px;
            padding: 10px;
            margin: 10px auto;
            border: none;
            border-radius: 5px;
            background-color: #4caf50;
            color: white;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #45a049;
        }

        #status {
            margin-top: 20px;
            font-weight: 700;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/web3/dist/web3.min.js"></script>
    <script>
        let contract;
        const contractAddress = '0xC96b2f89863FFCD4Dd9681d7AB096B92b46E4407';
        const abi = [
            {
                "inputs": [],
                "name": "houseBalance",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "address"
                    }
                ],
                "name": "games",
                "outputs": [
                    {
                        "internalType": "address",
                        "name": "player",
                        "type": "address"
                    },
                    {
                        "internalType": "enum CoinFlip.Bet",
                        "name": "bet",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bool",
                        "name": "isActive",
                        "type": "bool"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "revealOutcome",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "enum CoinFlip.Bet",
                        "name": "_bet",
                        "type": "uint8"
                    }
                ],
                "name": "placeBet",
                "outputs": [],
                "stateMutability": "payable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_amount",
                        "type": "uint256"
                    }
                ],
                "name": "withdraw",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "player",
                        "type": "address"
                    },
                    {
                        "indexed": false,
                        "internalType": "enum CoinFlip.Bet",
                        "name": "bet",
                        "type": "uint8"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "name": "GameCreated",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "player",
                        "type": "address"
                    },
                    {
                        "indexed": false,
                        "internalType": "bool",
                        "name": "won",
                        "type": "bool"
                    },
                    {
                        "indexed": false,
                        "internalType": "enum CoinFlip.Bet",
                        "name": "result",
                        "type": "uint8"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "name": "GameResult",
                "type": "event"
            }
        ];

        window.onload = async () => {
            if (window.ethereum) {
                window.web3 = new Web3(window.ethereum);
                await window.ethereum.enable();
                contract = new web3.eth.Contract(abi, contractAddress);
            } else {
                alert('Please install MetaMask!');
            }
        };

        async function placeBet(bet) {
            const accounts = await web3.eth.getAccounts();
            const betValue = web3.utils.toWei('0.0001', 'ether');
            contract.methods.placeBet(bet).send({ from: accounts[0], value: betValue })
                .on('receipt', function(receipt) {
                    document.getElementById('status').textContent = 'Bet placed!';
                })
                .on('error', function(error) {
                    console.error(error);
                    document.getElementById('status').textContent = 'Error placing bet.';
                });
        }

        async function revealOutcome() {
            const accounts = await web3.eth.getAccounts();
            contract.methods.revealOutcome().send({ from: accounts[0] })
                .on('receipt', function(receipt) {
                    document.getElementById('status').textContent = 'Check your wallet, you will get 0.0002 ETH if you win';
                })
                .on('error', function(error) {
                    console.error(error);
                    document.getElementById('status').textContent = 'Error revealing outcome.';
                });
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>Head or Tail Prediction Game</h1>
        <button onclick="placeBet(1)">Bet on Heads</button>
        <button onclick="placeBet(2)">Bet on Tails</button>
        <button onclick="revealOutcome()">Reveal Outcome</button>
        <div id="status">Place your bet!</div>
    </div>
</body>
</html>
EOL

echo -e "\033[1;34mFolder 'hca' and file 'app.html' created successfully.\033[0m"
echo

echo -e "\033[1;34mInstalling ethfs-cli globally...\033[0m"
echo
npm install -g ethfs-cli || { echo "Failed to install ethfs-cli"; exit 1; }
echo

read -p 'Enter your private key: ' PRIVATE_KEY
echo

echo -e "\033[1;34mCreating a new filesystem with ethfs-cli...\033[0m"
echo
echo -e "\033[1;35mCOPY THIS DIRECTORY ADDRESS AND SAVE IT SOMEWHERE\033[0m"
echo
ethfs-cli create -p "$PRIVATE_KEY" -c 11155111 || { echo "Failed to create filesystem with ethfs-cli"; exit 1; }
echo

read -p 'Enter the flat directory address: ' FLAT_DIR_ADDRESS
echo

echo -e "\033[1;34mUploading 'hca' folder with ethfs-cli...\033[0m"
echo
ethfs-cli upload -f "$WORKDIR/hca" -a "$FLAT_DIR_ADDRESS" -c 11155111 -p "$PRIVATE_KEY" -t 1 || { echo "Failed to upload folder with ethfs-cli"; exit 1; }
echo

echo -e "\033[1;34mInstalling eth-blob-uploader globally...\033[0m"
echo
npm install -g eth-blob-uploader || { echo "Failed to install eth-blob-uploader"; exit 1; }
echo

read -p 'Enter any EVM wallet address: ' EVM_WALLET_ADDRESS
echo

echo -e "\033[1;34mUploading 'app.html' with eth-blob-uploader...\033[0m"
echo
eth-blob-uploader -r http://88.99.30.186:8545 -p "$PRIVATE_KEY" -f "$WORKDIR/hca/app.html" -t "$EVM_WALLET_ADDRESS" || { echo "Failed to upload app.html with eth-blob-uploader"; exit 1; }
echo

echo -e "\033[1;34mCreating a new filesystem again with ethfs-cli...\033[0m"
echo
echo -e "\033[1;35mCOPY THIS DIRECTORY ADDRESS AND SAVE IT SOMEWHERE\033[0m"
echo
ethfs-cli create -p "$PRIVATE_KEY" -c 11155111 || { echo "Failed to create filesystem with ethfs-cli"; exit 1; }
echo

read -p 'Enter the flat directory address: ' FLAT_DIR_ADDRESS2
echo

echo -e "\033[1;34mUploading 'hca' folder again with ethfs-cli...\033[0m"
echo
echo -e "\033[1;31mThis transaction may get stuck, You should wait 2 mins. If it is still the same, start the script from the beginning\033[0m"
echo
ethfs-cli upload -f "$WORKDIR/hca" -a "$FLAT_DIR_ADDRESS2" -c 11155111 -p "$PRIVATE_KEY" -t 2 || { echo "Failed to upload folder with ethfs-cli"; exit 1; }
echo

echo -e "\033[1;32mThis is your application’s web3 link:\033[0m https://"$FLAT_DIR_ADDRESS2".3333.w3link.io/app.html"
echo

echo -e "\033[1;32mAll tasks completed successfully.\033[0m"
echo
