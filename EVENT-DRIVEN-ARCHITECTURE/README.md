# Event-Driven Architecture with AWS SQS

This project demonstrates **Event-Driven Architecture (EDA)** using AWS services for automated file processing. EDA is a software architecture pattern where components communicate through events, enabling loose coupling, scalability, and resilience.

## Event-Driven Architecture Overview

**Event-Driven Architecture** is a design pattern where:
- **Events** trigger actions across distributed systems
- **Producers** generate events without knowing consumers
- **Consumers** react to events independently
- **Event Brokers** route messages between components

### Benefits of EDA:
- **Loose Coupling**: Components don't directly depend on each other
- **Scalability**: Each component can scale independently
- **Resilience**: Failures in one component don't cascade
- **Real-time Processing**: Events are processed as they occur

## Architecture Implementation

This infrastructure demonstrates EDA principles:

```
S3 Upload → S3 Event → SQS Queue → Lambda Function → S3 Destination
   ↓           ↓          ↓            ↓              ↓
Producer    Event    Event Broker   Consumer       Action
```

### Components:
- **Event Producer**: S3 bucket generates events on file uploads
- **Event Broker**: SQS queue manages event delivery and retry logic
- **Event Consumer**: Lambda function processes events asynchronously
- **Dead Letter Queue**: Handles failed message processing
- **Monitoring**: CloudWatch tracks system health

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Python 3.12 (for Lambda function)

## Deployment

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update values:
   ```hcl
   region = "us-east-1"
   source_bucket_name = "your-source-bucket-name"
   destination_bucket_name = "your-destination-bucket-name"
   ```

3. Initialize and deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Event Flow

1. **Event Generation**: File upload to S3 triggers ObjectCreated event
2. **Event Publishing**: S3 publishes event to SQS queue
3. **Event Processing**: Lambda polls SQS and processes messages
4. **Event Action**: Files are copied to destination bucket
5. **Event Completion**: Successful messages are deleted from queue
6. **Error Handling**: Failed messages move to dead letter queue

## EDA Patterns Demonstrated

- **Publisher-Subscriber**: S3 publishes events, Lambda subscribes
- **Message Queuing**: SQS provides reliable message delivery
- **Dead Letter Queue**: Handles poison messages and failures
- **Batch Processing**: Lambda processes multiple events together
- **Retry Logic**: Built-in retry mechanism with exponential backoff

## Cleanup

```bash
terraform destroy
```

## File Structure

```
├── lambda/
│   └── index.py          # Lambda function code
├── main.tf               # Main infrastructure resources
├── variables.tf          # Input variables
├── outputs.tf           # Output values
├── terraform.tf         # Terraform configuration
└── terraform.tfvars     # Variable values (not in git)
```