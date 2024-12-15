output "function_arns" {
  description = "Map of Lambda function ARNs"
  value = {
    for k, v in aws_lambda_function.functions : k => v.arn
  }
}

output "function_names" {
  description = "Map of Lambda function names"
  value = {
    for k, v in aws_lambda_function.functions : k => v.function_name
  }
}

output "role_arn" {
  description = "ARN of the IAM role used by Lambda functions"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_function_ids" {
  value = {
    for k, v in aws_lambda_function.functions : k => v.id
  }
}

