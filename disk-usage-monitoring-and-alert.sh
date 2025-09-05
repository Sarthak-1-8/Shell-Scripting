#!/bin/bash

# === CONFIGURATION ===

THRESHOLD=80                           # Set alert threshold (in percentage)
ALERT_EMAIL="user@ubuntu-pc"            # Set your alert email (optional)
LOG_FILE="$HOME/disk_usage_report.log"  # Where the report gets saved

# === CHECK DISK USAGE AND LOG ===
echo "=== Disk Usage Report - $(date) ===" > "$LOG_FILE"
echo "Mount Point | Usage (%) | Status" >> "$LOG_FILE"
echo "------------------------------------" >> "$LOG_FILE"

df -hP | grep -vE '^Filesystem|tmpfs|cdrom' | while read line; do
  USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
  MOUNT=$(echo "$line" | awk '{print $6}')

  if [ "$USAGE" -ge "$THRESHOLD" ]; then
    STATUS="ALERT: High Usage"
  else
    STATUS="Normal"
  fi

  echo "$MOUNT | $USAGE% | $STATUS" >> "$LOG_FILE"
done

# === SEND ALERT IF USAGE EXCEEDED ===
if grep -q "ALERT" "$LOG_FILE"; then
  echo "Disk usage alert triggered." | mail -s "Disk Space Alert" "$ALERT_EMAIL"
fi


