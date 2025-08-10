# AWS SSM Connect Infrastructure

This Terraform project creates a secure AWS infrastructure for connecting to EC2 instances using AWS Systems Manager (SSM) Session Manager without requiring SSH keys or bastion hosts.

## Architecture

The infrastructure includes:
- **VPC** with private subnet (no internet gateway)
- **EC2 instance** in private subnet
- **VPC Endpoints** for SSM services (ssm, ssmmessages, ec2messages, logs, s3)
- **Session logging** to S3 and CloudWatch with KMS encryption
- **IAM roles** and policies for SSM access

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Appropriate AWS permissions for creating VPC, EC2, IAM, and SSM resources

## Quick Start

1. Clone and navigate to the project directory
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review and modify variables in `variables.tf` if needed
4. Plan the deployment:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region for deployment | `us-west-2` |
| `availability_zone` | Availability zone for resources | `us-west-2a` |
| `bucket_name` | S3 bucket name for session logs | `my-session-logs-bucket6464` |

### Customization

Update `variables.tf` with your preferred values before deployment.

## Connecting to Instances

After deployment, connect to your EC2 instance using:

```bash
aws ssm start-session --target <instance-id>
```

Get the instance ID from Terraform output:
```bash
terraform output instance_id
```

## Security Features

- **No SSH keys required** - Uses SSM for secure access
- **Private subnet only** - No direct internet access
- **Session logging** - All sessions logged to S3 and CloudWatch
- **KMS encryption** - All logs encrypted at rest
- **VPC endpoints** - Secure communication without internet gateway

## File Structure

```
├── main.tf           # VPC, subnets, VPC endpoints, SSM configuration
├── ec2.tf           # EC2 instances and security groups
├── s3.tf            # S3 bucket for session logs
├── cloudwatch.tf    # CloudWatch log groups and KMS keys
├── provider.tf      # AWS provider configuration
├── backend.tf       # Terraform backend configuration
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # This file
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

- Ensure your AWS credentials have sufficient permissions
- Verify the availability zone exists in your chosen region
- Check that the S3 bucket name is globally unique
- Review CloudWatch logs for session activity

## License

This project is provided as-is for educational and demonstration purposes.