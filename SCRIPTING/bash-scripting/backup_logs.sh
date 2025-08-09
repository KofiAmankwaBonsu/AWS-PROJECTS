#!/bin/bash

LOG_DIR="/var/log"
BACKUP_FILE="/home/ec2-user/log_backup_$(date +%F).tar.gz"

tar -czf "$BACKUP_FILE" "$LOG_DIR" >> /home/ec2-user/cron_log_backup.log 2>&1
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE" >> /home/ec2-user/cron_log_backup.log
else
    echo "Backup failed" >> /home/ec2-user/cron_log_backup.log
fi
