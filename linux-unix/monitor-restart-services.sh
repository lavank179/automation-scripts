#!/bin/bash

SERVICES_LIST=("nginx" "ssh" "mysql")

List_And_Restart_Services(){
  for SERVICE in "${SERVICES_LIST[@]}"; do
    if [[ $(systemctl is-active $SERVICE) != "active" ]]; then
      echo "$(date): $SERVICE is down. Attempting to restart..."
      sudo systemctl restart $SERVICE

      if [[ $(systemctl is-active $SERVICE) == "active" ]]; then
        echo "$(date): $SERVICE restarted successfully!"
      else
        echo "$(date): Failed to restart $SERVICE. Manual intervention required."
      fi
    else
      echo "$(date): $SERVICE is running"
    fi
  done
}

Stop_Services(){
  for SERVICE in "${SERVICES_LIST[@]}"; do
    if [[ $(systemctl is-active $SERVICE) == "active" ]]; then
      echo "$(date): Stopping $SERVICE..."
      sudo systemctl stop $SERVICE

      if [[ $(systemctl is-active $SERVICE) != "active" ]]; then
        echo "$(date): $SERVICE stopped successfully!"
      else
        echo "$(date): Failed to stops $SERVICE. Manual intervention required."
      fi
    fi
  done
}

# Dispatch function based on first argument from command line
if [[ "$1" == "Stop_Services" ]]; then
  Stop_Services
else
  List_And_Restart_Services
fi
