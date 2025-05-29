#!/bin/bash
Threshold=70
Disk_Name="/mnt/c" #windows

send_alert() {
  message=$1
  echo "$message"
}

check_disk_usage() {
  
  Cpu_Usage=$(df -Ph | grep -E $Disk_Name | awk '{print $5}' | sed 's/%//g')
  if [[ "$Cpu_Usage" -gt "$Threshold" ]]; then
    send_alert "CPU Usage on $Disk_Name is above the threshold $Threshold% - current usage: $Cpu_Usage%"
  else
    echo "CPU Usage on $Disk_Name is under the threshold $Threshold% - current usage: $Cpu_Usage%"
  fi
}

check_disk_usage