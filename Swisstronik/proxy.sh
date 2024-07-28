#!/bin/sh

wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 4

sudo apt-get update && sudo apt get upgrade -y
clear

echo "Installing dependencies..."
npm install --save-dev hardhat
npm install dotenv
npm install @swisstronik/utils
npm install @openzeppelin/hardhat-upgrades
npm install @openzeppelin/contracts
npm install @nomicfoundation/hardhat-toolbox
echo "Installation completed."

echo "Creating a Hardhat project..."
npx hardhat

rm -f contracts/Lock.sol
echo "Lock.sol removed."

echo "Hardhat project created."

echo "Installing Hardhat toolbox..."
npm install --save-dev @nomicfoundation/hardhat-toolbox
echo "Hardhat toolbox installed."

echo "Creating .env file..."
read -p "Enter your private key: " PRIVATE_KEY
echo "PRIVATE_KEY=$PRIVATE_KEY" > .env
echo ".env file created."

echo "Configuring Hardhat..."
cat <<EOL > hardhat.config.js
require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    swisstronik: {
      url: "https://json-rpc.testnet.swisstronik.com/",
      accounts: [\`0x\${process.env.PRIVATE_KEY}\`],
    },
  },
};
EOL
echo "Hardhat configuration completed."

echo "Creating Hello_swtr.sol contract..."
mkdir -p contracts
cat <<EOL > contracts/Hello_swtr.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Swisstronik {
    string private message;

    function initialize(string memory _message) public {
        message = _message;
    }

    function setMessage(string memory _message) public {
        message = _message;
    }

    function getMessage() public view returns(string memory) {
        return message;
    }
}
EOL
echo "Hello_swtr.sol contract created."

echo "Compiling the contract..."
npx hardhat compile
echo "Contract compiled."

echo "Creating deploy.js script..."
mkdir -p scripts
cat <<EOL > scripts/deploy.js
const fs = require("fs");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Swisstronik = await ethers.getContractFactory('Swisstronik');
  const swisstronik = await Swisstronik.deploy();
  await swisstronik.waitForDeployment(); 
  console.log('Non-proxy Swisstronik deployed to:', swisstronik.target);
  fs.writeFileSync("contract.txt", swisstronik.target);

  const upgradedSwisstronik = await upgrades.deployProxy(Swisstronik, ['Hello Swisstronik from Happy Cuan Airdrop!!'], { kind: 'transparent' });
  await upgradedSwisstronik.waitForDeployment(); 
  console.log('Proxy Swisstronik deployed to:', upgradedSwisstronik.target);
  fs.writeFileSync("proxiedContract.txt", upgradedSwisstronik.target);

  console.log(\`Deployment transaction hash: https://explorer-evm.testnet.swisstronik.com/address/\${upgradedSwisstronik.target}\`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
EOL
echo "deploy.js script created."

echo "Deploying the contract..."
npx hardhat run scripts/deploy.js --network swisstronik
echo "Contract deployed."

echo "Creating setMessage.js script..."
cat <<EOL > scripts/setMessage.js
const hre = require("hardhat");
const { encryptDataField, decryptNodeResponse } = require("@swisstronik/utils");
const fs = require("fs");

const sendShieldedTransaction = async (signer, destination, data, value) => {
  const rpclink = hre.network.config.url;
  const [encryptedData] = await encryptDataField(rpclink, data);
  return await signer.sendTransaction({
    from: signer.address,
    to: destination,
    data: encryptedData,
    value,
  });
};

async function main() {
  const contractAddress = fs.readFileSync("proxiedContract.txt", "utf8").trim();
  const [signer] = await hre.ethers.getSigners();
  const contractFactory = await hre.ethers.getContractFactory("Swisstronik");
  const contract = contractFactory.attach(contractAddress);
  const functionName = "setMessage";
  const messageToSet = "Hello Swisstronik from Happy Cuan Airdrop!!";
  const setMessageTx = await sendShieldedTransaction(signer, contractAddress, contract.interface.encodeFunctionData(functionName, [messageToSet]), 0);
  await setMessageTx.wait();
  console.log("Transaction Receipt: ", setMessageTx);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
EOL
echo "setMessage.js script created."

echo "Running setMessage.js..."
npx hardhat run scripts/setMessage.js --network swisstronik
echo "Message set."

echo "Creating getMessage.js script..."
cat <<EOL > scripts/getMessage.js
const hre = require("hardhat");
const { encryptDataField, decryptNodeResponse } = require("@swisstronik/utils");
const fs = require("fs");

const sendShieldedQuery = async (provider, destination, data) => {
  const rpclink = hre.network.config.url;
  const [encryptedData, usedEncryptedKey] = await encryptDataField(rpclink, data);
  const response = await provider.call({
    to: destination,
    data: encryptedData,
  });
  return await decryptNodeResponse(rpclink, response, usedEncryptedKey);
};

async function main() {
  const contractAddress = fs.readFileSync("proxiedContract.txt", "utf8").trim();
  const [signer] = await hre.ethers.getSigners();
  const contractFactory = await hre.ethers.getContractFactory("Swisstronik");
  const contract = contractFactory.attach(contractAddress);
  const functionName = "getMessage";
  const responseMessage = await sendShieldedQuery(signer.provider, contractAddress, contract.interface.encodeFunctionData(functionName));
  console.log("Decoded response:", contract.interface.decodeFunctionResult(functionName, responseMessage)[0]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
EOL
echo "getMessage.js script created."

echo "Running getMessage.js..."
npx hardhat run scripts/getMessage.js --network swisstronik
echo "Message retrieved."
echo "Done! Subscribe: https://t.me/HappyCuanAirdrop"