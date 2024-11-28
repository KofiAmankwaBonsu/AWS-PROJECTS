#!/bin/bash

# Part 1: Apache Web Server Installation and Configuration
echo "Starting Apache installation and configuration..."
yum update -y
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple test page
echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
chown -R apache:apache /var/www/html
