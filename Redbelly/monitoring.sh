#!/bin/bash

### === CONFIGURATION === ###
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""

LOG_FILE="/var/log/redbelly/rbn_logs/rbbc_logs.log"
RPC_URL="https://governors.mainnet.redbelly.network"

### === FUNCTIONS === ###
get_local_block() {
  grep -oE '"number": "0x[0-9a-fA-F]+"' "$LOG_FILE" |
    tail -n 1 |
    grep -oE '0x[0-9a-fA-F]+' |
    xargs -I {} printf "%d\n" {}
}

get_network_block() {
  curl -s -X POST "$RPC_URL" \
    -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' |
    jq -r '.result' | xargs -I {} printf "%d\n" {}
}

get_cpu_load() {
  awk -F'load average:' '{print $2}' < <(uptime) | sed 's/^[ \t]*//'
}

get_ram_usage() {
  mem=$(free -m | awk '/^Mem:/ {print $3, $2}')
  echo "${mem}MB"
}

get_disk_usage() {
  df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}'
}

send_telegram_message() {
  local message=$1
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=${message}" \
    -d "parse_mode=HTML" >/dev/null
}

build_report() {
  local_block=$(get_local_block)
  net_block=$(get_network_block)

  [ -z "$local_block" ] && local_block="N/A"
  [ -z "$net_block" ] && net_block="N/A"

  if [[ "$local_block" != "N/A" && "$net_block" != "N/A" ]]; then
    diff=$((net_block - local_block))
    [ "$diff" -lt 0 ] && diff=$((local_block - net_block))
    status=$([[ "$diff" -le 1 ]] && echo "✅ <b>Synced</b>" || echo "❌ <b>Out of Sync</b>")
  else
    diff="?"
    status="⚠️ <b>Error Reading Block</b>"
  fi

  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  cpu_load=$(get_cpu_load)
  ram_stats=$(get_ram_usage)
  disk_stats=$(get_disk_usage)

  echo "<b>📡 Ramanode – Redbelly Node Monitor 📡</b>%0A""\
<b>🕓 Time:</b> $timestamp%0A""\
<b>📦 Local Block:</b> $local_block%0A""\
<b>🌍 Network Block:</b> $net_block%0A""\
<b>📉 Lag:</b> $diff blocks%0A""\
<b>📌 Status:</b> $status%0A""\
%0A""\
<b>🖥 System Health</b>%0A""\
<b>💡 CPU Load:</b> $cpu_load%0A""\
<b>🧠 RAM:</b> $ram_stats%0A""\
<b>💾 Disk:</b> $disk_stats"
}

### === MAIN LOOP === ###
while true; do
  message=$(build_report)
  send_telegram_message "$message"
  sleep 60
done
