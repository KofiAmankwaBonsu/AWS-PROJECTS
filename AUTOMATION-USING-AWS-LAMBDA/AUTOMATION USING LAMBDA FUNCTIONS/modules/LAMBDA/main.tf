resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-lambda-maintenance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.environment}-lambda-maintenance-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:CreateSnapshot",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "functions" {
  for_each = var.lambda_functions

  filename      = each.value.filename
  function_name = "${var.environment}-${each.key}"
  role          = aws_iam_role.lambda_role.arn
  handler       = each.value.handler
  runtime       = each.value.runtime
  memory_size   = each.value.memory_size
  timeout       = each.value.timeout

  environment {
    variables = merge(
      {
        INSTANCE_ID = var.instance_id
        ENVIRONMENT = var.environment
      },
      each.value.environment_variables
    )
  }

  tags = {
    Environment = var.environment
    Function    = each.key
  }
}
