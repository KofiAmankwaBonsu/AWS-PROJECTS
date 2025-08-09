resource "aws_sns_topic" "topics" {
  for_each = var.topics
  name     = "${var.environment}-${each.value.name}"


  tags = {
    Environment = var.environment
    Name        = each.value.name
  }
}

resource "aws_sns_topic_policy" "default" {
  for_each = aws_sns_topic.topics

  arn = each.value.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DefaultSNSPolicy"
        Effect = "Allow"
        Principal = {
          Service = [
            "events.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
        Action   = "SNS:Publish"
        Resource = each.value.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "subscriptions" {
  for_each = var.subscriptions

  topic_arn = aws_sns_topic.topics[each.value.topic_name].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}
