#!/bin/bash
# Note: send_mail.sh is a custom script to send mail via curl.

# CONFIGS
DISK_THRESHOLD="30" #%
MEM_THRESHOLD_CRITICAL=80 #%
MEM_THRESHOLD_WARNING=50 #%
CPU_THRESHOLD=70 #%
HOST=$(hostname)
NOW=$(date +"%m-%d-%Y %H:%M:%S")
MAIL_ID="dev@test.com"
LOOP_DELAY_SECONDS=5

#-----------------------------------UTILS--------------------------------------
#Fill spaces to string to look neat.
fill(){
  str=$1
  size=${#str} # eg. str = test
  space_to_fill=$(( 30 - size )) # It adds 30-4=26 spaces to the str.
  for i in $(seq 1 $space_to_fill);
  do
    str="$str "
  done
  echo "$str"
}
clean_files(){
  filename=$1
  do_clean=$2
  if [[ $do_clean == "remove" ]]; then
    rm $filename
  elif [[ $do_clean == "recreate" ]]; then
    if [[ -e "$filename" ]]; then
      rm $filename
    fi
    touch $filename
  fi
}

#-----------------------------------DISK-MONITOR--------------------------------------
disk_monitor() {
  local output="disk_monitor.txt"
  clean_files $output "recreate"

  echo -e "=========================Disk Space Exceeded Threshold($DISK_THRESHOLD%) on $HOST at $NOW========================\n" >> $output
  echo -e "=========================FOLDERS/MOUNTS OCCUPIED MORE THAN LIMIT==========================\n" >> $output
  echo -e "Partion                       Mount                         Usage %                       " >> $output
  
  usage=0
  while read line;
  do
    partition=$(echo $line | awk '{ print $1}')
    mount=$(echo $line | awk '{ print $6}')
    usage=$(echo $line | awk '{ print $5}' | sed 's/%//')

    if [[ "$usage" -gt "$DISK_THRESHOLD" ]]; then
      raw="$(fill "$partition")$(fill "$mount")$(fill "$usage")"
      f=$(printf "%s" "$raw" | tr -d '\n')
      echo -e "$f" >> $output
    fi
  done < <(df -Ph | grep -vE "tmpfs|Filesystem|devtmps|snap|loop*")

  if [[ "$usage" -gt "$DISK_THRESHOLD" ]]; then
    ./send_mail.sh $MAIL_ID "Disk Utilization High on $HOST. Usage: $DISK_THRESHOLD%" $output
    echo "Email sent!"
  fi
}

#-----------------------------------MEMORY-MONITOR--------------------------------------
get_mem_usage(){
  local output="memory_monitor.txt"
  clean_files $output "recreate"

  mem_total=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')
  mem_available=$(grep 'MemAvailable' /proc/meminfo | awk '{print $2}')
  mem_used=$((mem_total-mem_available))
  mem_used_percent=$((mem_used*100/mem_total))

  if [[ $mem_used_percent -gt $MEM_THRESHOLD_WARNING ]] && [[ $mem_used_percent -lt $MEM_THRESHOLD_CRITICAL ]]; then
    echo -e "===================WARNING: Memory Utilization is high on $HOST at $NOW===================\n\n" >> $output
    echo -e "Current: $mem_used_percent%            Threshold: $MEM_THRESHOLD_WARNING%                                     \n\n" >> $output
    echo -e "Total: $((mem_total / 1024))Mb         Used: $((mem_used / 1024))Mb        Free: $((mem_available / 1024))Mb\n\n" >> $output
    echo -e "==========================Top Processess consuming system memory==========================\n" >> $output
    echo -e "$(ps -eo user,pid,%mem,%cpu,start,command --sort=-%mem | head -n 15)" >> $output
    printf "******************************************************************************************" >> $output
    ./send_mail.sh $MAIL_ID "Memory Utilization is high on $HOST at $NOW. Usage: $mem_used_percent%" $output
    echo "Email sent!"
  elif [[ $mem_used_percent -gt $MEM_THRESHOLD_CRITICAL ]]; then
    echo -e "===================CRITICAL: Memory Utilization is high on $HOST at $NOW===================\n\n" >> $output
    echo -e "Current: $mem_used_percent%            Threshold: $MEM_THRESHOLD_CRITICAL%                                     \n\n" >> $output
    echo -e "Total: $((mem_total / 1024))Mb         Used: $((mem_used / 1024))Mb        Free: $((mem_available / 1024))Mb\n\n" >> $output
    echo -e "==========================Top Processess consuming system memory==========================\n" >> $output
    echo -e "$(ps -eo user,pid,%mem,%cpu,start,command --sort=-%mem | head -n 15)" >> $output
    printf "******************************************************************************************" >> $output
    ./send_mail.sh $MAIL_ID "Memory Utilization is high on $HOST at $NOW. Usage: $mem_used_percent%" $output
    echo "Email sent!"
  fi
}

#-----------------------------------CPU-MONITOR--------------------------------------
get_cpu_usage(){
  time_now=$(date +%s)
  cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk -F , '{print $4}' | tr -d %id)
  cpu_percent=$(echo "100.0 - $cpu_idle" | bc -l)

  local output="cpu_monitor.txt"
  clean_files $output "recreate"

  local temp_cpu="temp_cpu.txt" # Saves timestamp and present cpu % to temp file
  if [[ -e $temp_cpu ]]; then
    first_line=$(head -n 1 "$temp_cpu" | awk '{print $1}') # reads first line 
    if [[ $first_line != "" && $((time_now-first_line)) -gt 20 ]]; then
      tail -n +2 "$temp_cpu" > temp && mv temp "$temp_cpu" # if first line time is more than 5 mins earlier, it deletes the first line.
    fi
  fi
  echo -e "$time_now $cpu_percent" >> $temp_cpu

  # once it has 4 cpu data, takes and avg them to get avg cpu of last 5 mins.
  if [[ $(wc -l < "$temp_cpu") -ge 4 ]]; then
    avg_cpu=0
    while IFS= read -r line; do
      lines_cpu=$(echo $line | awk '{print $2}')
      avg_cpu=$(echo "$avg_cpu+$lines_cpu" | bc -l)
    done < $temp_cpu

    avg_cpu=$(echo "scale=0; $avg_cpu/4" | bc -l)
    if [[ $avg_cpu -gt $CPU_THRESHOLD ]]; then
      echo -e "===================CRITICAL: CPU Utilization is high($avg_cpu%) on $HOST at $NOW===================\n\n" >> $output
      echo -e "Usage since last 5min: $avg_cpu%                   Total Cores: $(nproc)\n\n" >> $output
      echo -e "==========================Top Processess consuming system memory==========================\n" >> $output
      echo -e "$(ps -eo user,pid,%mem,%cpu,start,command --sort=-%cpu | head -n 15)" >> $output
      printf "******************************************************************************************" >> $output
      ./send_mail.sh $MAIL_ID "CRITICAL: CPU Utilization is high($avg_cpu%) on $HOST at $NOW." $output
      echo "Email sent!"
    fi
  fi
}

rm -f "temp_cpu.txt" 1>/dev/null
while true; do
  get_cpu_usage
  disk_monitor
  get_mem_usage
  echo "Completed a run!"
  sleep $LOOP_DELAY_SECONDS
done