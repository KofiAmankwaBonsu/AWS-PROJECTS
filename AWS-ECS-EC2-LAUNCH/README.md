# AWS ECS EC2 Launch Terraform Configuration

This Terraform configuration deploys a containerized application on AWS ECS using EC2 launch type with an Application Load Balancer.

## Architecture Overview

- **ECS Cluster**: Manages containerized applications
- **EC2 Auto Scaling Group**: Provides compute capacity for ECS tasks
- **Application Load Balancer**: Distributes traffic to containers
- **ECR Repository**: Stores Docker images
- **CloudWatch**: Logs and monitoring

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version compatible with AWS provider ~> 5.0)
- Docker installed for building and pushing images

## Quick Start

1. **Clone and navigate to the project**:
   ```bash
   cd AWS-ECS-EC2-LAUNCH
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

5. **Build and push your Docker image** (use the commands from terraform output):
   ```bash
   terraform output docker_commands
   ```

## Configuration Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `app_name` | Application name | string | `react-app` |
| `aws_region` | AWS region | string | `us-east-1` |
| `container_port` | Container port | number | `3000` |
| `desired_count` | Number of containers to run | number | `1` |

## Customization

Create a `terraform.tfvars` file to override defaults:

```hcl
app_name       = "my-app"
aws_region     = "us-west-2"
container_port = 8080
desired_count  = 2
```

## Outputs

After deployment, Terraform provides:

- **ALB DNS Name**: Access your application
- **ECR Repository URL**: For pushing Docker images
- **Docker Commands**: Ready-to-use commands for image deployment

## Resources Created

### Networking
- Uses default VPC and subnets (excludes us-east-1e)
- Security groups for ALB, ECS instances, and tasks

### Compute
- ECS cluster with EC2 launch type
- Auto Scaling Group (1-3 instances, t3.micro)
- Launch template with ECS-optimized AMI

### Load Balancing
- Application Load Balancer
- Target group with health checks
- HTTP listener on port 80

### Container Registry
- ECR repository with force delete enabled

### Monitoring
- CloudWatch log group with 1-day retention

## Security Groups

- **ALB**: Allows HTTP (port 80) from anywhere
- **ECS Instances**: Allows SSH (port 22) from anywhere
- **ECS Tasks**: Allows container port from ALB only

## Deployment Workflow

1. Deploy infrastructure with Terraform
2. Build your Docker image
3. Push image to ECR repository
4. ECS automatically pulls and runs the image

## Accessing Your Application

After deployment, get the load balancer URL:
```bash
terraform output alb_dns_name
```

## Updating Your Application

To deploy a new version:
1. Build and push new Docker image with `:latest` tag
2. Force ECS service update (command provided in terraform output)

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Important Notes

- Uses remote backend for state management
- ECR repository has force delete enabled
- CloudWatch logs retained for 1 day only
- Auto Scaling Group scales between 1-3 instances
- Health checks configured for HTTP 200 responses on "/"

## Troubleshooting

- Ensure your Docker image exposes the correct port (default: 3000)
- Verify your application responds to health checks on "/"
- Check ECS service events in AWS Console for deployment issues
- Review CloudWatch logs for application errors