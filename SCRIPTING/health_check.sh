#!/bin/bash

SERVICE="httpd"

if ! systemctl is-active --quiet "$SERVICE"; then
    echo "$(date): $SERVICE is down. Restarting..." >> /var/log/health_check.log
    systemctl restart "$SERVICE"
fi

