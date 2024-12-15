aws_region      = "us-east-1"
environment     = "dev"
vpc_id          = "vpc-0ff5f2a7c49a90655"    # Replace with your VPC ID
subnet_id       = "subnet-0be7fafdab0e15793" # Replace with your Subnet ID
instance_type   = "t2.micro"
start_schedule  = "cron(35 20 * * ? *)"
stop_schedule   = "cron(30 20 * * ? *)"
backup_schedule = "cron(40 20 * * ? *)"
