output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "Public IP of the created EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.monitoring.dashboard_name}"
}

output "instance_details" {
  description = "Details of the created EC2 instance"
  value = {
    id        = module.ec2.instance_id
    public_ip = module.ec2.instance_public_ip
  }
}

output "schedules" {
  description = "Created EventBridge schedules"
  value       = module.scheduling.schedule_names
}


output "lambda_functions" {
  value = {
    start  = module.lambda.function_arns["start-instances"]
    stop   = module.lambda.function_arns["stop-instances"]
    backup = module.lambda.function_arns["backup-instances"]
  }
}

output "schedule_rules" {
  value = {
    start  = module.scheduling.schedule_rules["start-daily"]
    stop   = module.scheduling.schedule_rules["stop-daily"]
    backup = module.scheduling.schedule_rules["backup-daily"]
  }
}

output "lambda_function_names" {
  value = {
    start  = module.lambda.function_names["start-instances"]
    stop   = module.lambda.function_names["stop-instances"]
    backup = module.lambda.function_names["backup-instances"]
  }
}

