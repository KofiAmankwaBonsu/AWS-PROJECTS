# AWS ECS Fargate Terraform Infrastructure

This Terraform project provisions AWS infrastructure for running containerized applications on Amazon ECS with Fargate launch type.

## Architecture

The infrastructure includes:
- **ECR Repository** - For storing Docker images
- **ECS Cluster** - Container orchestration cluster
- **ECS Service** - Manages running containers
- **ECS Task Definition** - Container configuration
- **IAM Roles** - Execution permissions for ECS tasks
- **Security Groups** - Network access control
- **CloudWatch Log Group** - Container logging

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Docker](https://www.docker.com/get-started) for building and pushing images

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd AWS-ECS-FARGATE
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review and customize variables (optional):**
   ```bash
   terraform plan
   ```

4. **Deploy infrastructure:**
   ```bash
   terraform apply
   ```

5. **Build and push your Docker image:**
   ```bash
   # Get ECR login command from Terraform output
   terraform output docker_push_commands
   
   # Execute the commands shown in the output
   ```

## Configuration

### Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `app_name` | Application name | `react-app` | string |
| `aws_region` | AWS region | `us-east-1` | string |
| `container_port` | Container port | `3000` | number |
| `desired_count` | Number of containers to run | `1` | number |

### Customization

Create a `terraform.tfvars` file to override defaults:

```hcl
app_name       = "my-app"
aws_region     = "us-west-2"
container_port = 8080
desired_count  = 2
```

## Outputs

After deployment, Terraform provides:
- `ecr_repository_url` - ECR repository URL for pushing images
- `ecs_cluster_name` - ECS cluster name
- `ecs_service_name` - ECS service name
- `docker_push_commands` - Ready-to-use Docker commands for image deployment

## Docker Image Requirements

Your Docker image should:
- Expose the port specified in `container_port` variable
- Be designed to run in a containerized environment
- Handle graceful shutdowns for ECS task management

## Deployment Workflow

1. **Deploy infrastructure** with Terraform
2. **Build your Docker image** locally
3. **Push image to ECR** using the provided commands
4. **Update ECS service** (automatic with latest tag)

## Resource Specifications

- **CPU**: 256 CPU units (0.25 vCPU)
- **Memory**: 512 MB
- **Network**: awsvpc mode with public IP assignment
- **Launch Type**: Fargate (serverless)

## Monitoring and Logs

- Container logs are automatically sent to CloudWatch
- Log group: `/ecs/{app_name}`
- Log retention: 1 day (configurable in main.tf)

## Security

- Uses default VPC and subnets
- Security group allows inbound traffic on container port
- IAM role follows least privilege principle
- ECR repository configured with force delete for development

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## File Structure

```
├── main.tf           # Main infrastructure resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── backend.tf        # Terraform state backend
└── README.md         # This file
```

## Troubleshooting

**Service not starting:**
- Check CloudWatch logs for container errors
- Verify Docker image runs locally on specified port
- Ensure ECR image exists and is accessible

**Cannot access application:**
- Verify security group allows traffic on container port
- Check if service has running tasks
- Confirm public IP assignment in network configuration

## Contributing

1. Make changes to Terraform files
2. Run `terraform plan` to review changes
3. Apply changes with `terraform apply`
4. Update documentation as needed