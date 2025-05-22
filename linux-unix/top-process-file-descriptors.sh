#!/bin/bash

get_fd_count_of_process() {
  pid=$1
  return $(ls -1 /proc/$pid/fd 2>/dev/null | wc -l)
}

get_all_fds() {
  pids=($(ps aux | awk 'NR > 1 {print $2}'))
  pnames=($(ps aux | awk 'NR > 1 {print $11}'))
  plength=${#pids[@]}

  for i in $(seq 1 "$plength"); do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    get_fd_count_of_process ${pids[$i]}
    fd_count=$?
    # limit=$(awk '/Max open files/ {print $4}' /proc/${pids[$i]}/limits)

    echo "[$timestamp] Process: ${pnames[$i]} | FDs: $fd_count"
  done
}

get_top_10_fds() {
  local top_n=${1:-10}
  echo -e "PID\tFDs\tProcess"

  # Loop over all numeric dirs in /proc (possible PIDs)
  for pid in /proc/[0-9]*; do
      pid=${pid#/proc/}
      
      # Skip if we can't access fd
      [ -r "/proc/$pid/fd" ] || continue

      get_fd_count_of_process $pid
      fd_count=$?
      
      # Get process name
      if [ -r "/proc/$pid/comm" ]; then
          pname=$(cat "/proc/$pid/comm")
      else
          pname="[unknown]"
      fi

      echo -e "$pid\t$fd_count\t$pname"
  done |
      sort -k2 -nr | head -n "$top_n"
}

get_all_fds
get_top_10_fds