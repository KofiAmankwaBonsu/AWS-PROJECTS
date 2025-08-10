# CloudFormation DataSync Template

This CloudFormation template provisions AWS DataSync infrastructure to automatically synchronize data from an S3 bucket to an Amazon EFS file system.

## Architecture Overview

The template creates a complete data synchronization solution with the following components:

- **VPC Infrastructure**: Custom VPC with public subnet and internet gateway
- **S3 Bucket**: Source bucket for data synchronization
- **Amazon EFS**: Target file system with encryption enabled
- **EC2 Instance**: Instance with EFS mounted for data access
- **AWS DataSync**: Automated data transfer service with scheduled tasks
- **Security Groups**: Properly configured security groups for secure communication
- **IAM Roles**: Service roles with minimal required permissions

## Resources Created

### Networking
- VPC with custom CIDR block
- Public subnet
- Internet Gateway and Route Table
- Security Groups for EC2, EFS, and DataSync

### Storage
- S3 bucket (source)
- EFS file system with encryption (destination)
- EFS mount target

### Compute
- EC2 instance with EFS client tools pre-installed
- Automatic EFS mounting via UserData script

### DataSync Components
- S3 location configuration
- EFS location configuration
- DataSync task with scheduled execution (daily at 6:30 PM UTC)

## Parameters

The template accepts the following parameters:

- **InstanceType**: EC2 instance type (default: t3.micro)
- **AmiID**: Amazon Linux 2 AMI ID for your region
- **VpcCidr**: CIDR block for the VPC (default: 10.0.0.0/16)
- **SubnetCidr**: CIDR block for the subnet (default: 10.0.1.0/24)

## Deployment Steps

### Prerequisites
- AWS CLI configured with appropriate permissions
- Access to AWS Management Console

### Option 1: AWS Management Console

1. **Navigate to CloudFormation**
   - Open the AWS Management Console
   - Go to Services → CloudFormation

2. **Create Stack**
   - Click "Create stack" → "With new resources (standard)"

3. **Upload Template**
   - Select "Upload a template file"
   - Choose the `datasync.yaml` file
   - Click "Next"

4. **Configure Stack**
   - Enter a stack name (e.g., `datasync-infrastructure`)
   - Review and modify parameters as needed:
     - **InstanceType**: Choose appropriate EC2 instance size
     - **AmiID**: Use the latest Amazon Linux 2 AMI for your region
     - **VpcCidr**: Adjust if needed to avoid conflicts
     - **SubnetCidr**: Ensure it's within the VPC CIDR range
   - Click "Next"

5. **Configure Stack Options**
   - Add tags if desired
   - Configure advanced options as needed
   - Click "Next"

6. **Review and Deploy**
   - Review all settings
   - Check "I acknowledge that AWS CloudFormation might create IAM resources"
   - Click "Create stack"

7. **Monitor Deployment**
   - Watch the Events tab for deployment progress
   - Deployment typically takes 5-10 minutes

### Option 2: AWS CLI

```bash
# Deploy the stack
aws cloudformation create-stack \
  --stack-name datasync-infrastructure \
  --template-body file://datasync.yaml \
  --parameters ParameterKey=InstanceType,ParameterValue=t3.micro \
               ParameterKey=AmiID,ParameterValue=ami-xxxxxxxxx \
  --capabilities CAPABILITY_IAM

# Monitor stack creation
aws cloudformation describe-stacks --stack-name datasync-infrastructure
```

## Post-Deployment

### Accessing Resources

After successful deployment, you can find the following in the Outputs section:

- **S3BucketName**: Name of the created S3 bucket
- **EfsFileSystemId**: EFS file system ID
- **EC2InstanceId**: EC2 instance for EFS access
- **DataSyncTaskArn**: ARN of the DataSync task

### Testing the Setup

1. **Upload test data to S3**:
   ```bash
   aws s3 cp test-file.txt s3://[S3BucketName]/
   ```

2. **Manually run DataSync task**:
   - Go to AWS DataSync console
   - Find your task and click "Start"
   - Monitor the execution

3. **Verify data on EFS**:
   - SSH to the EC2 instance
   - Check `/mnt/efs` directory for synchronized files

### DataSync Schedule

The DataSync task is configured to run automatically every day at 6:30 PM UTC. You can modify the schedule by updating the `ScheduleExpression` in the template.

## Security Considerations

- EFS file system is encrypted at rest
- Security groups follow least privilege principle
- IAM roles have minimal required permissions
- EC2 instance allows SSH access (consider restricting source IP)

## Cleanup

To avoid ongoing charges, delete the CloudFormation stack when no longer needed:

```bash
# Empty S3 bucket first (if it contains data)
aws s3 rm s3://[S3BucketName] --recursive

# Delete the stack
aws cloudformation delete-stack --stack-name datasync-infrastructure
```

## Troubleshooting

### Common Issues

1. **EFS Mount Fails**: Check security group rules and VPC configuration
2. **DataSync Task Fails**: Verify IAM permissions and network connectivity
3. **Stack Creation Fails**: Check parameter values and region-specific AMI IDs

### Logs and Monitoring

- CloudFormation events in the AWS Console
- DataSync task execution history
- EC2 instance logs via SSH or CloudWatch

## Cost Optimization

- Use appropriate EC2 instance types
- Consider EFS Infrequent Access storage class
- Monitor DataSync transfer costs
- Set up billing alerts

## Support

For issues related to:
- AWS services: Contact AWS Support
- Template modifications: Review AWS CloudFormation documentation
- DataSync configuration: Check AWS DataSync user guide