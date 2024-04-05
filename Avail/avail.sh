#!/bin/bash

show_hca_logo() {
    echo "Showing HCA logo..."
    wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
    curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
    sleep 2
}

remove_existing_avail_script() {
    if [ -f "avail.sh" ]; then
        echo "Removing existing avail.sh file..."
        rm avail.sh
    fi
}

download_avail_script() {
    echo "Downloading avail.sh script..."
    wget -O avail.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/avail.sh
}

setup_avail_service() {
    sudo tee /etc/systemd/system/avail.service > /dev/null <<EOF
[Unit]
Description=Avail Light Client
After=network.target
StartLimitIntervalSec=0

[Service]
User=$USER
Restart=always
RestartSec=5
ExecStart=$HOME/.avail/bin/avail-light --network goldberg --config $HOME/.avail/config/config.yml --app-id 0 --identity $HOME/.avail/identity/identity.toml
LimitNOFILE=65000

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable avail
    sudo systemctl start avail
}

check_logs() {
    read -p "Do you want to check logs (y/n)? " choice
    if [ "$choice" = "y" ]; then
        sudo journalctl -fu avail -o cat
    fi
}

main() {
    show_hca_logo
    remove_existing_avail_script
    download_avail_script
    setup_avail_service
    check_logs
}

main
