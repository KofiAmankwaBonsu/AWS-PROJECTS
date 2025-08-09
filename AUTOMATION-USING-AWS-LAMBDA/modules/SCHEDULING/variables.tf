variable "environment" {
  description = "Environment name"
  type        = string
}

variable "schedules" {
  description = "Map of schedules to create"
  type = map(object({
    description         = string
    schedule_expression = string
    lambda_function_arn = string
    input_parameters    = map(string)
  }))
}
