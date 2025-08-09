#!/bin/bash

THRESHOLD=10

df -h | grep '^/dev/' | while read line; do
  USAGE=$(echo $line | awk '{print $5}' | tr -d '%')
  PART=$(echo $line | awk '{print $6}')
  if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "$(date): Disk usage warning on $PART - $USAGE% used." >> /var/log/disk_alert.log
  fi
done