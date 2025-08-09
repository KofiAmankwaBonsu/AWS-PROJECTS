resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${var.environment}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"

  dimensions = {
    InstanceId = var.instance_id
  }
}

# Lambda invocation alarm
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each            = var.lambda_function_name
  alarm_name          = "${var.environment}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors Lambda function errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# EC2 and Lambda Monitoring Dashboard"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id],
            ["AWS/EC2", "NetworkIn", "InstanceId", var.instance_id],
            ["AWS/EC2", "NetworkOut", "InstanceId", var.instance_id],
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", var.instance_id],
          ],
          period  = 300,
          stat    = "Average",
          region  = var.aws_region,
          title   = "EC2 Instance Metrics",
          view    = "timeSeries",
          stacked = false
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "MemoryUtilization", "InstanceId", var.instance_id],
            ["AWS/EC2", "DiskSpaceUtilization", "InstanceId", var.instance_id],
            ["AWS/EC2", "CPUCreditBalance", "InstanceId", var.instance_id],
            ["AWS/EC2", "CPUCreditUsage", "InstanceId", var.instance_id],
          ],
          period  = 300,
          stat    = "Average",
          region  = var.aws_region,
          title   = "EC2 Resource Utilization",
          view    = "timeSeries",
          stacked = false
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.environment}-start-instances"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.environment}-stop-instances"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.environment}-backup-instances"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.environment}-start-instances"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.environment}-stop-instances"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.environment}-backup-instances"]
          ],
          period  = 300,
          stat    = "Sum",
          region  = var.aws_region,
          title   = "Lambda Invocations and Errors",
          view    = "timeSeries",
          stacked = false
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 7
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", "${var.environment}-start-instances"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.environment}-stop-instances"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.environment}-backup-instances"],
            ["AWS/Lambda", "Throttles", "FunctionName", "${var.environment}-start-instances"],
            ["AWS/Lambda", "Throttles", "FunctionName", "${var.environment}-stop-instances"],
            ["AWS/Lambda", "Throttles", "FunctionName", "${var.environment}-backup-instances"]
          ],
          period  = 300,
          stat    = "Average",
          region  = var.aws_region,
          title   = "Lambda Duration and Throttles",
          view    = "timeSeries",
          stacked = false
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 13
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${var.environment}-start-instances"],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${var.environment}-stop-instances"],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${var.environment}-backup-instances"]
          ],
          period  = 300,
          stat    = "Maximum",
          region  = var.aws_region,
          title   = "Lambda Concurrent Executions",
          view    = "timeSeries",
          stacked = true
        }
      }
    ]
  })
}

