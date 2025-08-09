#!/bin/bash

# Update system packages
sudo yum update -y

# Install Apache HTTP Server
sudo yum install -y httpd

# Start httpd service
sudo systemctl start httpd

# Enable httpd to start on boot
sudo systemctl enable httpd

# Check if httpd is running
if systemctl is-active --quiet httpd; then
    echo "httpd installed and started successfully"
else
    echo "Failed to start httpd"
fi