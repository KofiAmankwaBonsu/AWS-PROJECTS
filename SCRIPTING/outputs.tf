output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.remediation.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}