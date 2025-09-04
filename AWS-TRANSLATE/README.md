# AWS Language Translator

A serverless language translation application built with AWS services and Terraform.

## Architecture

- **Frontend**: EC2 instance with Apache serving HTML/CSS/JS
- **API**: API Gateway with CORS-enabled endpoints
- **Backend**: Lambda function using AWS Translate service
- **Infrastructure**: Terraform-managed with auto-generated SSH keys

## Features

- Real-time text translation between 6 languages
- Responsive web interface
- Serverless backend with AWS Lambda
- Infrastructure as Code with Terraform

## Supported Languages

- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- PuTTY (for Windows SSH access)

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Deploy infrastructure**:
   ```bash
   terraform apply
   ```

3. **Get outputs**:
   ```bash
   # Web server URL
   terraform output web_server_url
   
   # API Gateway URL
   terraform output api_gateway_url
   ```

## SSH Access

1. **Extract private key**:
   ```bash
   terraform output -raw ssh_private_key > private_key.pem
   ```

2. **Convert to PPK (Windows)**:
   - Use PuTTYgen to convert `private_key.pem` to `private_key.ppk`

3. **Connect**:
   ```bash
   ssh -i private_key.pem ec2-user@<instance-ip>
   ```

## File Structure

```
aws-translate/
├── main.tf              # Lambda function and IAM roles
├── api.tf               # API Gateway configuration
├── ec2.tf               # EC2 instance and networking
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values
├── user_data.sh         # EC2 initialization script
├── index.html           # Frontend HTML
├── styles.css           # Frontend CSS
└── lambda/
    └── index.js         # Lambda function code
```

## Cleanup

```bash
terraform destroy
```

## Security Notes

- SSH access (port 22) is open to 0.0.0.0/0 - restrict in production
- API Gateway has CORS enabled for all origins
- Lambda function has minimal IAM permissions

## Troubleshooting

- Check Lambda logs in CloudWatch: `/aws/lambda/translate-function`
- Verify EC2 security group allows HTTP (port 80)
- Ensure AWS Translate service is available in your region