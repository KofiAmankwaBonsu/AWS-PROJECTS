# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "auth-lambda-role"

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

# IAM policy for Lambda functions
resource "aws_iam_role_policy" "lambda_policy" {
  name = "auth-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminRespondToAuthChallenge",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminSetUserPassword"
        ]
        Resource = [aws_cognito_user_pool.auth_pool.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [aws_dynamodb_table.otp_table.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# Initiate Auth Lambda
resource "aws_lambda_function" "initiate_auth" {
  filename         = data.archive_file.initiate_auth.output_path
  source_code_hash = data.archive_file.initiate_auth.output_base64sha256
  function_name    = "initiate-auth"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30

  environment {
    variables = {
      CLIENT_ID    = var.cognito_client_id
      USER_POOL_ID = var.cognito_user_pool_id
      OTP_TABLE    = aws_dynamodb_table.otp_table.name
      FROM_EMAIL   = var.from_email
    }
  }
}

# Verify OTP Lambda
resource "aws_lambda_function" "verify_otp" {
  filename         = data.archive_file.verify_otp.output_path
  source_code_hash = data.archive_file.verify_otp.output_base64sha256
  function_name    = "verify-otp"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30

  environment {
    variables = {
      CLIENT_ID    = var.cognito_client_id
      USER_POOL_ID = var.cognito_user_pool_id
      OTP_TABLE    = aws_dynamodb_table.otp_table.name
      FROM_EMAIL   = var.from_email
    }
  }
}

# Archive for initiate_auth Lambda
data "archive_file" "initiate_auth" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/initiate-auth"
  output_path = "${path.module}/dist/initiate-auth.zip"
}

# Archive for verify_otp Lambda
data "archive_file" "verify_otp" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/verify-otp"
  output_path = "${path.module}/dist/verify-otp.zip"
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "api_gateway_initiate" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.initiate_auth.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.auth_api.execution_arn}/*/${aws_api_gateway_method.initiate_post.http_method}${aws_api_gateway_resource.initiate.path}"
}

resource "aws_lambda_permission" "api_gateway_verify" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.verify_otp.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.auth_api.execution_arn}/*/${aws_api_gateway_method.verify_post.http_method}${aws_api_gateway_resource.verify.path}"
}


# cognito.tf
resource "aws_cognito_user_pool" "auth_pool" {
  name = "auth-user-pool"

  # Email Configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = true
    require_symbols   = false
    require_uppercase = false
  }

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # MFA Configuration
  mfa_configuration = "OFF"

  admin_create_user_config {
    allow_admin_create_user_only = false
    
    # We suppress Cognito emails since we use SES
    invite_message_template {
      email_subject = "Your verification code"
      email_message = "Hello {username},\nYour temporary password is: {####}\nPlease use this to sign in."
      sms_message   = "Hello {username}, your temporary password is: {####}"
    }
  }
  


  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "auth_client" {
  name = "auth-client"

  user_pool_id = aws_cognito_user_pool.auth_pool.id

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
  generate_secret               = false


}

# DynamoDB table for OTP storage
resource "aws_dynamodb_table" "otp_table" {
  name         = "otp-storage"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

