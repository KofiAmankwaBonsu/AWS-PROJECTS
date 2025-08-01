output "account_id" {
  description = "The ID of the created AWS account"
  value       = aws_organizations_account.account.id
}

output "account_arn" {
  description = "The ARN of the created AWS account"
  value       = aws_organizations_account.account.arn
}

output "organizational_unit_id" {
  description = "The ID of the organizational unit"
  value       = aws_organizations_organizational_unit.ou.id
}