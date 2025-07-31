# AWS VPC Peering Terraform Infrastructure

This Terraform project creates a complete VPC peering setup with two VPCs, EC2 instances, and all necessary networking components for cross-VPC communication.

## Architecture

The infrastructure creates:
- **Requester VPC** (10.0.0.0/16) with public subnet and EC2 instance
- **Accepter VPC** (172.16.0.0/16) with public subnet and EC2 instance  
- **VPC Peering Connection** enabling communication between both VPCs
- **Auto-generated SSH Key Pair** for EC2 access

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with VPC creation permissions

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd VPC-PEERING
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review and modify variables:**
   ```bash
   # Edit terraform.tfvars with your preferred values
   ```

4. **Deploy the infrastructure:**
   ```bash
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

| Variable | Description | Default |
|----------|-------------|----------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `requester_vpc_cidr` | CIDR block for requester VPC | `10.0.0.0/16` |
| `accepter_vpc_cidr` | CIDR block for accepter VPC | `172.16.0.0/16` |
| `requester_subnet_cidr` | Public subnet CIDR for requester VPC | `10.0.1.0/24` |
| `accepter_subnet_cidr` | Public subnet CIDR for accepter VPC | `172.16.1.0/24` |
| `ami_id` | AMI ID for EC2 instances | `ami-0453ec754f44f9a4a` |
| `instance_type` | EC2 instance type | `t2.micro` |
| `key_name` | Name for the generated SSH key pair | `my-key-pair` |
| `availability_zones` | List of AZs for subnet placement | `["us-east-1a", "us-east-1b"]` |

## Outputs

After deployment, you'll receive:
- Public and private IP addresses of both EC2 instances
- SSH private key file (`<key_name>.pem`) for instance access

## Testing Connectivity

1. **SSH into requester instance:**
   ```bash
   chmod 400 my-key-pair.pem
   ssh -i my-key-pair.pem ec2-user@<requester_public_ip>
   ```

2. **Test connectivity to accepter instance:**
   ```bash
   ping <accepter_private_ip>
   ```

## Module Structure

```
├── modules/
│   ├── network/     # VPC, subnet, routing components
│   ├── peering/     # VPC peering connection and routes
│   └── compute/     # EC2 instances and security groups
├── main.tf          # Main configuration
├── variables.tf     # Variable definitions
├── outputs.tf       # Output definitions
└── terraform.tfvars # Variable values
```

## Cleanup

```bash
terraform destroy
```

## Security Notes

- SSH key pair is auto-generated with 2048-bit RSA encryption
- Private key file has restrictive permissions (0600)
- Security groups allow SSH (22) and ICMP for testing
 
