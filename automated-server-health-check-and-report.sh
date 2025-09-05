# !/bin/bash
########################################
# automated-server-health-check-and-report-script
# This script performs an automated system health check by collecting metrics related to CPU, memory, disk, 
# and network usage. The output can be logged or emailed, and alerts are triggered when usage crosses defined thresholds.

########################3
#---------------------#
# USER-CONFIGURABLE PARAMETERS
#---------------------#
cpu_threshold=90
mem_threshold=90
disk_threshold=90
report_file="$HOME/server_health_report.txt"   # Write report to your home directory
email_recipient=""   # e.g. "admin@example.com" - leave blank for no email notifications

#---------------------#
# COLLECT STATISTICS
#---------------------#
current_time=$(date '+%Y-%m-%d %H:%M:%S')

# CPU Usage (total usage %)
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)

# Memory Usage (% used)
mem=$(free | awk '/Mem/ {printf("%.0f", ($3/$2)*100)}')

# Disk Usage for root (as %)
disk=$(df -P / | awk 'END{print $5}' | tr -d '%')

# Network usage: bytes in/out in last second (for enp0s8; change if needed)
interface="enp0s8"
rx1=$(cat /sys/class/net/"$interface"/statistics/rx_bytes)
tx1=$(cat /sys/class/net/"$interface"/statistics/tx_bytes)
sleep 1
rx2=$(cat /sys/class/net/"$interface"/statistics/rx_bytes)
tx2=$(cat /sys/class/net/"$interface"/statistics/tx_bytes)
network_rx=$(( (rx2 - rx1)/1024 ))  # KB/s
network_tx=$(( (tx2 - tx1)/1024 ))  # KB/s

#---------------------#
# BUILD REPORT
#---------------------#
report="
===========================================
Automated Server Health Check Report
Date: $current_time
-------------------------------------------
CPU Usage     : ${cpu}%
Memory Usage  : ${mem}%
Disk Usage    : ${disk}%
Network RX    : ${network_rx} KB/s
Network TX    : ${network_tx} KB/s
-------------------------------------------
"

status="ok. all metrics within thresholds."
send_alert=0

if [ "$cpu" -ge "$cpu_threshold" ]; then
    status="alert: cpu usage critical (${cpu}%)!"
    send_alert=1
fi

if [ "$mem" -ge "$mem_threshold" ]; then
    status="alert: memory usage critical (${mem}%)!"
    send_alert=1
fi

if [ "$disk" -ge "$disk_threshold" ]; then
    status="alert: disk usage critical (${disk}%)!"
    send_alert=1
fi

#---------------------#
# SAVE REPORT & ALERT
#---------------------#
echo "${report}status: $status
===========================================" > "$report_file"

if [ "$send_alert" -eq 1 ] && [ -n "$email_recipient" ]; then
    cat "$report_file" | mail -s "Server Health ALERT" "$email_recipient"
fi

echo "Health report generated at $report_file"
