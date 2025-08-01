output "account_ids" {
  description = "Map of account names to their IDs"
  value       = { for k, v in module.accounts : k => v.account_id }
}

output "account_arns" {
  description = "Map of account names to their ARNs"
  value       = { for k, v in module.accounts : k => v.account_arn }
}

output "sso_portal_url" {
  description = "AWS SSO access portal URL"
  value       = "https://${split("/", local.sso_instance_arn)[1]}.awsapps.com/start"
}