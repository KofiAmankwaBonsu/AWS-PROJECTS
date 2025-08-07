# Security Group Remediation & System Monitoring

Automated AWS security group monitoring with comprehensive system maintenance scripts for proactive infrastructure management.

## Overview

This system provides:
- **Automated Security Group Remediation**: Removes risky rules from EC2 security groups via Lambda
- **System Health Monitoring**: Automated disk, service, and backup monitoring
- **Proactive Alerting**: SNS notifications for security violations and system issues
- **Infrastructure Maintenance**: Automated backups, syncing, and service management

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CloudWatch    │───▶│  Lambda Function │───▶│   SNS Topic     │
│   EventBridge   │    │  (External)      │    │   (Alerts)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Cron Jobs      │───▶│  Shell Scripts   │───▶│  System Actions │
│  (Internal)     │    │  (Monitoring)    │    │  (Backup/Sync)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Components

### External Scripting (AWS Lambda)

**File**: `security_group_remediation.py`
- **Purpose**: Cloud-based security monitoring
- **Trigger**: CloudWatch EventBridge (every 10 minutes)
- **Actions**: 
  - Scans all running EC2 instances
  - Identifies risky security group rules (ports 22, 3306, 25 open to 0.0.0.0/0)
  - Automatically removes dangerous rules
  - Sends SNS alerts

**Deployment**:
```bash
# Set notification email
export TF_VAR_notification_email="your-email@company.com"

# Deploy infrastructure
terraform init
terraform plan
terraform apply
```

### Internal Scripting (Shell Scripts)

**File**: `backup_logs.sh`
- **Purpose**: Automated log backup system
- **Schedule**: Daily via cron
- **Actions**: Creates compressed backup of /var/log directory
```bash
#!/bin/bash
LOG_DIR="/var/log"
BACKUP_FILE="/home/ec2-user/log_backup_$(date +%F).tar.gz"
tar -czf "$BACKUP_FILE" "$LOG_DIR" >> /home/ec2-user/cron_log_backup.log 2>&1
```

**File**: `check_disk.sh`
- **Purpose**: Disk usage monitoring with alerts
- **Schedule**: Every 15 minutes via cron
- **Actions**: Monitors disk usage and logs warnings when threshold exceeded
```bash
#!/bin/bash
THRESHOLD=10
df -h | grep '^/dev/' | while read line; do
  USAGE=$(echo $line | awk '{print $5}' | tr -d '%')
  if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "$(date): Disk usage warning - $USAGE% used" >> /var/log/disk_alert.log
  fi
done
```
**File**: `install_httpd.sh`
- **Purpose**: Apache web server installation and setup
- **Usage**: Run once during server initialization
- **Actions**: Installs, starts, and enables Apache HTTP server
```bash
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
```


**File**: `health_check.sh`
- **Purpose**: Service health monitoring and auto-restart
- **Schedule**: Every 5 minutes via cron
- **Actions**: Monitors httpd service and restarts if down
```bash
#!/bin/bash
SERVICE="httpd"
if ! systemctl is-active --quiet "$SERVICE"; then
    echo "$(date): $SERVICE is down. Restarting..." >> /var/log/health_check.log
    systemctl restart "$SERVICE"
fi
```


**File**: `s3_sync.sh`
- **Purpose**: Automated S3 synchronization for backups
- **Schedule**: Daily via cron
- **Actions**: Syncs web content to S3 bucket with logging
```bash
#!/bin/bash
SOURCE="/var/www/html"
DESTINATION="s3://my-tf-state6464/ec2-backup/"
aws s3 sync "$SOURCE" "$DESTINATION" --delete >> /var/log/s3_sync.log 2>&1
```

## Usage

### 1. Deploy AWS Infrastructure

# Deploy Lambda function and SNS
terraform init
terraform apply

### 2. Setup Local System Monitoring
```bash
# Make scripts executable
chmod +x *.sh

# Install Apache (one-time setup)
./install_httpd.sh

# Setup cron jobs for automated monitoring
# Add to crontab (crontab -e):
*/15 * * * * /path/to/check_disk.sh
*/5 * * * * /path/to/health_check.sh
0 2 * * * /path/to/backup_logs.sh
0 3 * * * /path/to/s3_sync.sh
```

### 3. Manual Operations
```bash
# Check disk usage immediately
./check_disk.sh

# Verify service health
./health_check.sh

# Create manual backup
./backup_logs.sh

# Sync to S3 manually
./s3_sync.sh
```

## Configuration

### Terraform Variables
Edit `terraform.tfvars`:
```hcl
notification_email = "your-email@company.com"
aws_region = "us-east-1"
lambda_function_name = "security-group-remediation"
```

### Shell Script Configuration

**Disk Monitoring Threshold** (`check_disk.sh`):
```bash
THRESHOLD=10  # Alert when disk usage exceeds 10%
```

**S3 Sync Destination** (`s3_sync.sh`):
```bash
SOURCE="/var/www/html"
DESTINATION="s3://your-bucket-name/backup/"
```

**Service Monitoring** (`health_check.sh`):
```bash
SERVICE="httpd"  # Change to monitor different service
```

## Monitoring & Alerts

### AWS Lambda Monitoring
- **Security Group Violations**: Automatic removal of risky rules
- **SNS Notifications**: Email alerts for security issues
- **CloudWatch Logs**: Lambda execution logs

### Local System Monitoring
- **Disk Usage**: Configurable threshold alerts (default 10%)
- **Service Health**: Automatic service restart (httpd)
- **Log Backups**: Daily compressed backups
- **S3 Sync**: Automated cloud backup with error logging

## Auto-remediation Actions

The system automatically handles:
- **Security Group Violations** → Remove risky rules via Lambda
- **Service Downtime** → Restart httpd service
- **Log Management** → Daily backup and S3 sync
- **Disk Monitoring** → Alert logging for manual intervention

## Files Structure

```
security-group-remediation/
├── README.md                     # This file
├── main.tf                      # Terraform infrastructure
├── variables.tf                 # Terraform variables
├── outputs.tf                   # Terraform outputs
├── backend.tf                   # Terraform backend config
├── terraform.tfvars             # Variable values
├── security_group_remediation.py # Lambda function (external)
├── backup_logs.sh               # Log backup automation (internal)
├── check_disk.sh                # Disk usage monitoring (internal)
├── health_check.sh              # Service health monitoring (internal)
├── install_httpd.sh             # Apache installation (internal)
└── s3_sync.sh                   # S3 backup sync (internal)
```

## Internal vs External Scripting

### Internal Scripting (Shell Scripts)
- **Location**: Run on EC2 instances/local servers
- **Purpose**: System administration, monitoring, backups
- **Advantages**: Direct system access, no cloud costs, immediate execution
- **Use Cases**: Disk monitoring, service health, log backups, S3 sync
- **Scheduling**: Cron jobs for automated execution

### External Scripting (AWS Lambda)
- **Location**: Run in AWS cloud (serverless)
- **Purpose**: AWS resource management and security
- **Advantages**: Serverless, automatic scaling, integrated with AWS services
- **Use Cases**: Security group monitoring, automated remediation, SNS alerts
- **Scheduling**: CloudWatch EventBridge triggers

## Troubleshooting

### Common Issues
1. **Permission denied**: Ensure scripts have execute permissions (`chmod +x *.sh`)
2. **AWS CLI not configured**: Run `aws configure` with proper credentials
3. **S3 sync fails**: Check bucket permissions and AWS credentials
4. **Lambda timeout**: Increase timeout in `main.tf` if processing many instances
5. **Service restart fails**: Check systemctl permissions and service status

### Log Locations
- **Lambda logs**: CloudWatch Logs `/aws/lambda/security-group-remediation`
- **Disk alerts**: `/var/log/disk_alert.log`
- **Health checks**: `/var/log/health_check.log`
- **Backup logs**: `/home/ec2-user/cron_log_backup.log`
- **S3 sync logs**: `/var/log/s3_sync.log`

## Security Considerations

- Lambda function has minimal IAM permissions (EC2 describe/modify, SNS publish)
- S3 bucket access requires proper IAM roles
- Log files contain system information - ensure proper file permissions
- Email alerts sent via SNS for security violations
- Regular log rotation prevents disk space issues

## Contributing

1. Test shell scripts locally before deployment
2. Update Terraform plan before applying infrastructure changes
3. Monitor CloudWatch logs after Lambda updates
4. Verify cron job schedules don't overlap
5. Test S3 sync permissions before automation