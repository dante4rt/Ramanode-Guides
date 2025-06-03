#!/bin/bash

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Please enter your API_ID (You can get it from https://my.telegram.org/auth?to=apps):"
read API_ID
echo "Please enter your API_HASH (You can get it from https://my.telegram.org/auth?to=apps):"
read API_HASH

if [ -d "YesCoinBot" ]; then
    echo "Removing existing YesCoinBot directory..."
    rm -rf YesCoinBot || {
        echo "Failed to remove existing YesCoinBot directory."
        exit 1
    }
fi

echo "Cloning the YesCoinBot repository..."
git clone https://github.com/shamhi/YesCoinBot.git || {
    echo "Failed to clone repository."
    exit 1
}
cd YesCoinBot || {
    echo "Failed to change directory."
    exit 1
}

echo "Setting up the virtual environment..."
echo "Installing Python 3.10 and necessary packages..."
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.10 python3.10-venv python3.10-dev -y || {
    echo "Failed to install Python 3.10 and necessary packages."
    exit 1
}

python3.10 -m venv venv || {
    echo "Failed to create virtual environment."
    exit 1
}
source venv/bin/activate || {
    echo "Failed to activate virtual environment."
    exit 1
}

echo "Installing required packages..."
pip install --upgrade pip
pip install wheel
pip install -r requirements.txt || {
    echo "Failed to install required packages."
    exit 1
}

echo "Configuring the .env file..."
cp .env-example .env || {
    echo "Failed to copy .env-example to .env."
    exit 1
}

sed -i "s/^API_ID=.*/API_ID=$API_ID/" .env
sed -i "s/^API_HASH=.*/API_HASH=$API_HASH/" .env

echo "You can edit other configurations in the .env file."
echo "Setup completed successfully."
