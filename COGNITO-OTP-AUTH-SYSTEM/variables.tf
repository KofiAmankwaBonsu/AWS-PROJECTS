variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "auth-system"
}

variable "cognito_client_id" {
  description = "Cognito client ID"
  type        = string

}

variable "cognito_user_pool_id" {
  description = "Cognito user pool ID"
  type        = string

}

variable "from_email" {
  description = "Email address to send OTP from (must be verified in SES)"
  type        = string
  default     = "noreply@example.com"
}


