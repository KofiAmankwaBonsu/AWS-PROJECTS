variable "account_name" {
  description = "The name of the AWS account to be created."
  type        = string
}

variable "account_email" {
  description = "The email address associated with the AWS account."
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.account_email))
    error_message = "The account_email must be a valid email address."
  }
}

variable "organizational_unit" {
  description = "The organizational unit where the account will be placed."
  type        = string
}

variable "environment" {
  description = "The environment tag for the account (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to the AWS account."
  type        = map(string)
  default     = {}
}

variable "organization_root_id" {
  description = "The root ID of the organization"
  type        = string
}