variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to manage"
  type        = string
}

variable "lambda_functions" {
  description = "Map of Lambda functions to create"
  type = map(object({
    filename              = string
    handler               = string
    runtime               = string
    memory_size           = number
    timeout               = number
    environment_variables = map(string)
  }))
}

variable "lambda_function_name" {
  description = "Map of Lambda function names and configurations"
  type = map(object({
    name        = string
    handler     = string
    runtime     = string
    memory_size = number
    timeout     = number
  }))
  default = {
    "start-instances" = {
      name        = "start-instances"
      handler     = "index.handler"
      runtime     = "python3.9"
      memory_size = 128
      timeout     = 30
    }
    "stop-instances" = {
      name        = "stop-instances"
      handler     = "index.handler"
      runtime     = "python3.9"
      memory_size = 128
      timeout     = 30
    }
    "backup-instances" = {
      name        = "backup-instances"
      handler     = "index.handler"
      runtime     = "python3.9"
      memory_size = 256
      timeout     = 60
    }
  }
}
