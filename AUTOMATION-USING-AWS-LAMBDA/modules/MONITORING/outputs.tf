output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_alarm.arn
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
