# Garbage Truck Fleet Management System

A web-based fleet management system for tracking garbage trucks, built with AWS serverless architecture.

## Architecture

- **Frontend**: Static HTML/CSS/JavaScript hosted on S3
- **Backend**: AWS Lambda with Node.js
- **Database**: DynamoDB
- **Infrastructure**: Terraform for AWS resource management
- **API**: API Gateway for REST endpoints

## Features

- View all trucks in the fleet
- Add new trucks to the system
- Track truck status (Active, Maintenance, Off-Duty)
- Monitor fuel levels and maintenance schedules
- Real-time fleet dashboard

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Node.js >= 18.x (for local development)

## Quick Start

1. **Clone and navigate to the project**
   ```bash
   cd gtruckapp/terraform
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Deploy infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

4. **Access the application**
   - The S3 website URL will be displayed in Terraform outputs
   - Open the URL in your browser to use the application

## Project Structure

```
gtruckapp/
└── terraform/
    ├── backend/
    │   └── lambda/
    │       └── index.js          # Lambda function code
    ├── frontend/
    │   ├── index.html           # Main application page
    │   ├── app.js              # Frontend JavaScript
    │   └── styles.css          # Application styles
    ├── *.tf                    # Terraform configuration files
    └── lambda.zip              # Packaged Lambda function
```

## API Endpoints

- `GET /trucks` - Retrieve all trucks
- `POST /trucks` - Add a new truck
- `OPTIONS /trucks` - CORS preflight

## Configuration

Default configuration can be modified in `variables.tf`:
- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project identifier
- `environment`: Environment name (default: dev)

## Cleanup

To destroy all AWS resources:
```bash
terraform destroy
```