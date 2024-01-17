#!/bin/bash
tput civis

# Clear Line
CL="\e[2K"
# Spinner Character
SPINNER="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

function spinner() {
  task=$1
  msg=$2
  while :; do
    jobs %1 > /dev/null 2>&1
    [ $? = 0 ] || {
      printf "${CL}✓ ${task} Done\n"
      break
    }
    for (( i=0; i<${#SPINNER}; i++ )); do
      sleep 0.05
      printf "${CL}${SPINNER:$i:1} ${task} ${msg}\r"
    done
  done
}

msg="${2-InProgress}"
task="${3-$1}"
$1 & spinner "$task" "$msg"

tput cnorm

# usage => ./loader.sh "<TIMER_TO_SLEEP>" "<PROGRESS>" "<TASK_NAME>"
# e.g => ./loader.sh "sleep 5" "..." "Installing Dependencies"
