# AWS EC2 Instance Automation with Lambda

Automated EC2 instance management using AWS Lambda functions with Terraform infrastructure as code. Includes scheduled start/stop operations, automated backups, monitoring, and notifications.

## Architecture

- **EC2 Module**: Creates managed EC2 instances
- **Lambda Functions**: Start, stop, and backup operations
- **EventBridge Scheduling**: Automated task execution
- **CloudWatch Monitoring**: Performance and health metrics
- **SNS Notifications**: Alert system for operations

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Python 3.9+
- Valid AWS VPC and subnet IDs

## Quick Setup

1. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your AWS details
   ```

2. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Update email notification**:
   - Replace `yourEmail` in main.tf with your email address
   - Confirm SNS subscription in your email

## Configuration

### Required Variables (terraform.tfvars)
```hcl
aws_region      = "us-east-1"
vpc_id          = "vpc-xxxxxxxxx"
subnet_id       = "subnet-xxxxxxxxx"
instance_type   = "t2.micro"
start_schedule  = "cron(0 8 ? * MON-FRI *)"
stop_schedule   = "cron(0 18 ? * MON-FRI *)"
backup_schedule = "cron(0 2 * * ? *)"
```

### Schedule Expressions
- Start: Weekdays 8 AM
- Stop: Weekdays 6 PM  
- Backup: Daily 2 AM
- Format: `cron(minute hour day month day-of-week year)`

## Lambda Functions

| Function | Purpose | Runtime | Timeout |
|----------|---------|---------|----------|
| start-instances | Start EC2 instances | Python 3.9 | 30s |
| stop-instances | Stop EC2 instances | Python 3.9 | 30s |
| backup-instances | Create EBS snapshots | Python 3.9 | 60s |

## Monitoring

- CloudWatch dashboard for instance metrics
- Lambda function monitoring
- SNS alerts for failures
- 7-day backup retention (configurable)

## Outputs

After deployment:
- Instance ID and public IP
- Lambda function ARNs
- CloudWatch dashboard URL
- EventBridge schedule names

## Cleanup

```bash
terraform destroy
```

## Cost Optimization

- Uses t2.micro instances (free tier eligible)
- Lambda functions with minimal memory allocation
- Automated start/stop reduces compute costs
- Configurable backup retention