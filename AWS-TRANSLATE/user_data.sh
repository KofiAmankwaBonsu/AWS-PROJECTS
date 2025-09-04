#!/bin/bash
yum update -y
yum install -y httpd

# Start and enable httpd
systemctl start httpd
systemctl enable httpd