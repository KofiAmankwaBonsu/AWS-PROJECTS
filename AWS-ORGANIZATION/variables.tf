variable "account_emails" {
  description = "Map of account names to email addresses"
  type        = map(string)
}

variable "accounts" {
  description = "Map of accounts to create"
  type = map(object({
    organizational_unit = string
    environment        = string
  }))
}

variable "demo_user_email" {
  description = "Email address for the demo SSO user"
  type        = string
}
