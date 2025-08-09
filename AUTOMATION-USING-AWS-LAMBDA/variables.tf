variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where EC2 instance will be created"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "start_schedule" {
  description = "Cron expression for starting instances"
  type        = string
}

variable "stop_schedule" {
  description = "Cron expression for stopping instances"
  type        = string
}

variable "backup_schedule" {
  description = "Cron expression for stopping instances"
  type        = string
}

variable "topics" {
  description = "Map of SNS topics to create"
  type = map(object({
    name        = string
    description = string
  }))
  default = {}
}

variable "subscriptions" {
  description = "Map of SNS topic subscriptions to create"
  type = map(object({
    topic_name = string
    protocol   = string
    endpoint   = string
  }))
  default = {}
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to monitor"
  type        = map(string)
  default = {
    "start-instances"  = "start-instances"
    "stop-instances"   = "stop-instances"
    "backup-instances" = "backup-instances"
  }
}
