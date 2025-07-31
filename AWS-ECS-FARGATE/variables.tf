variable "app_name" {
  description = "Application name"
  type        = string
  default     = "react-app"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of containers to run"
  type        = number
  default     = 1
}
