# AWS Auto Scaling Group with Application Load Balancer

A Terraform configuration for deploying a highly available, scalable web infrastructure on AWS using Auto Scaling Groups (ASG) and Application Load Balancer (ALB).

## Architecture Overview

This infrastructure creates:
- **VPC** with public subnets across multiple AZs
- **Application Load Balancer** for traffic distribution
- **Auto Scaling Group** with launch template
- **Target tracking scaling policies** based on CPU utilization
- **Security groups** for web traffic (HTTP/SSH)
- **CloudWatch alarms** for monitoring and scaling

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   git clone <repository-url>
   cd ASG-ALB
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Plan the deployment:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

5. **Access your application:**
   - Use the ALB DNS name from the output to access your web servers

## Configuration

### Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `aws_region` | AWS region for deployment | `us-east-1` | string |
| `vpc_name` | Name for the VPC | `demo_vpc` | string |
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` | string |
| `public_subnets` | Public subnet configuration | `{"public_subnet_1" = 1, "public_subnet_2" = 2}` | map |

### Auto Scaling Configuration

- **Min Size:** 1 instance
- **Max Size:** 4 instances  
- **Desired Capacity:** 2 instances
- **Instance Type:** t2.micro
- **Health Check:** ELB-based
- **Scaling Policy:** Target tracking (60% CPU utilization)

## Outputs

- `vpc_information`: VPC details and ID
- `public_subnet_ids_list`: List of public subnet IDs

## Security

- Security group allows HTTP (port 80) and SSH (port 22) access
- Instances deployed in public subnets with auto-assigned public IPs
- All outbound traffic allowed

## Monitoring & Scaling

- **Scale Out:** When CPU > 60% (target tracking)
- **Scale In:** When CPU < 30% for 3 consecutive periods (10 minutes each)
- **Cooldown:** 5 minutes between scaling activities

## Cleanup

```bash
terraform destroy
```

## Files Structure

```
.
├── main.tf           # Main Terraform configuration
├── variables.tf      # Variable definitions
├── outputs.tf        # Output definitions
├── user_data.sh      # EC2 instance initialization script
└── README.md         # This file
```

## Cost Optimization

- Uses t2.micro instances (eligible for free tier)
- Auto scaling ensures you only pay for needed capacity
- Target tracking scaling optimizes resource utilization

