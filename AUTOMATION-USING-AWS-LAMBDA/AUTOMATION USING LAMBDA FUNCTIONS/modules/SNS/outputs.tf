output "topic_arns" {
  description = "Map of topic names to their ARNs"
  value       = { for k, v in aws_sns_topic.topics : k => v.arn }
}

output "topic_names" {
  description = "Map of topic names to their names"
  value       = { for k, v in aws_sns_topic.topics : k => v.name }
}

output "subscription_arns" {
  description = "Map of subscription names to their ARNs"
  value       = { for k, v in aws_sns_topic_subscription.subscriptions : k => v.arn }
}
