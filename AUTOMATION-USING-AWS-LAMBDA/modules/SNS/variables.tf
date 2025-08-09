# modules/SNS/variables.tf
variable "topics" {
  description = "Map of SNS topics to create"
  type = map(object({
    name        = string
    description = string
  }))
}

variable "subscriptions" {
  description = "Map of SNS topic subscriptions"
  type = map(object({
    topic_name = string
    protocol   = string
    endpoint   = string
  }))
}

variable "environment" {
  description = "Environment name"
  type        = string
}

