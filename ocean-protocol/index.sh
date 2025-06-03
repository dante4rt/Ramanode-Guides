#!/bin/bash

OCEAN_REPO="https://github.com/dknodes/ocean.git"
OCEAN_FOLDER="$HOME/ocean"
PORT_RANGES=("8108" "2003:2015" "3003:3015" "4003:4015" "5003:5015")
MAX_NODES=12

check_and_open_ports() {
  for port_range in "${PORT_RANGES[@]}"; do
    if [[ "$port_range" == *:* ]]; then
      port_start=${port_range%:*}
      port_end=${port_range#*:}
      range_description="$port_start to $port_end"

      for ((port = $port_start; port <= $port_end; port++)); do
        if ! sudo ufw status | grep -q "$port"; then
          echo "🔒 Port $port is not allowed. Opening it with ufw..."
          sudo ufw allow "$port" && echo "✅ Port $port opened successfully." || echo "❌ Failed to open port $port."
        else
          echo "✅ Port $port is already allowed."
        fi
      done
    else
      if sudo ufw status | grep -q "$port_range"; then
        echo "✅ Port $port_range is already allowed."
      else
        echo "🔒 Port $port_range is not allowed. Opening it with ufw..."
        sudo ufw allow "$port_range" && echo "✅ Port $port_range opened successfully." || echo "❌ Failed to open port $port_range."
      fi
    fi
  done
}

check_existing_install() {
  if [ -d "$OCEAN_FOLDER" ]; then
    echo "⚠️ Ocean directory already exists. To reinstall, delete or backup the current folder first."
    return 0
  fi
  return 1
}

install_ocean_nodes() {
  read -p "Enter the number of nodes to deploy (max $MAX_NODES): " node_count
  if ((node_count < 1 || node_count > MAX_NODES)); then
    echo "❌ Please enter a number between 1 and $MAX_NODES."
    exit 1
  fi

  echo "Starting installation of $node_count nodes..."
  sudo bash -c "git clone $OCEAN_REPO && cd ocean && chmod ugo+x ocean.sh && ./ocean.sh"

  if [ $? -eq 0 ]; then
    echo "✅ Nodes installation completed successfully."
  else
    echo "❌ Installation encountered issues. Please check."
  fi
}

view_node_logs() {
  read -p "Enter node number to view logs (e.g., 1 for node-1): " node_number
  sudo docker logs -f ocean-node-$node_number
}

manage_nodes() {
  echo "Select an option:
  1) Stop a node
  2) Restart a node
  3) Delete all nodes
  4) Re-run the installation script"

  read -p "Enter your choice: " choice
  case $choice in
  1)
    read -p "Enter node number to stop (e.g., 1 for node-1): " node_number
    sudo docker-compose -f "$OCEAN_FOLDER/docker-compose${node_number}.yaml" down
    echo "Node $node_number stopped."
    ;;
  2)
    read -p "Enter node number to restart (e.g., 1 for node-1): " node_number
    sudo docker-compose -f "$OCEAN_FOLDER/docker-compose${node_number}.yaml" down &&
      sudo docker-compose -f "$OCEAN_FOLDER/docker-compose${node_number}.yaml" up -d
    echo "Node $node_number restarted."
    ;;
  3)
    echo "Stopping and removing all Ocean Protocol nodes and Typesense containers..."
    docker ps -a --filter "name=ocean-node" --filter "name=typesense" -q | xargs -r docker stop
    docker ps -a --filter "name=ocean-node" --filter "name=typesense" -q | xargs -r docker rm
    rm -rf "$OCEAN_FOLDER"
    echo "✅ All nodes and configurations deleted."
    ;;
  4)
    cd "$OCEAN_FOLDER" && ./ocean.sh
    ;;
  *)
    echo "Invalid option. Exiting."
    ;;
  esac
}

echo "Showing HCA logo..."
wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "🚀 Ocean Protocol Multi-Node Manager"
echo ""

cd $HOME
sudo apt update -y
sudo apt upgrade -y

check_and_open_ports
if check_existing_install; then
  echo "Select an option:
  1) Deploy new nodes
  2) View logs
  3) Manage nodes (stop, restart, delete)"

  read -p "Enter your choice: " choice
  case $choice in
  1)
    install_ocean_nodes
    ;;
  2)
    view_node_logs
    ;;
  3)
    manage_nodes
    ;;
  *)
    echo "Invalid option. Exiting."
    ;;
  esac
else
  install_ocean_nodes
fi

echo "✅ Setup completed. You can check your nodes status at https://nodes.oceanprotocol.com."
echo "Subscribe: https://t.me/HappyCuanAirdrop."
