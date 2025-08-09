output "schedule_arns" {
  description = "Map of EventBridge rule ARNs"
  value = {
    for k, v in aws_cloudwatch_event_rule.schedules : k => v.arn
  }
}

output "schedule_names" {
  description = "Map of EventBridge rule names"
  value = {
    for k, v in aws_cloudwatch_event_rule.schedules : k => v.name
  }
}

output "schedule_rules" {
  value = {
    for k, v in aws_cloudwatch_event_rule.schedules : k => v.name
  }
}

