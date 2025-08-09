variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to monitor"
  type        = string
}

variable "lambda_function_ids" {
  description = "Map of Lambda function IDs to monitor"
  type        = map(string)
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarm"
  type        = number
  default     = 80
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for alarm"
  type        = number
  default     = 2
}

variable "period_seconds" {
  description = "Period in seconds for metrics"
  type        = number
  default     = 300
}

variable "lambda_function_name" {
  description = "Map of Lambda function names"
  type        = map(string)
  default = {
    "start-instances"  = "start-instances"
    "stop-instances"   = "stop-instances"
    "backup-instances" = "backup-instances"
  }
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  type        = string
}

