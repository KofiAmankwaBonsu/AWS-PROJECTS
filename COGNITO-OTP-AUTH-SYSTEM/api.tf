resource "aws_api_gateway_rest_api" "auth_api" {
  name        = "auth-api"
  description = "Authentication API Gateway"
}

resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_rest_api.auth_api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
 
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name          = "cognito-authorizer"
  type          = "COGNITO_USER_POOLS" #for future protected endpoints
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  provider_arns = [aws_cognito_user_pool.auth_pool.arn]
}

# Initiate auth endpoint
resource "aws_api_gateway_resource" "initiate" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "initiate"
}

resource "aws_api_gateway_method" "initiate_post" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.initiate.id
  http_method   = "POST"
  authorization = "NONE"


  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

resource "aws_api_gateway_method_response" "initiate_200" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.initiate.id
  http_method = aws_api_gateway_method.initiate_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

# Add OPTIONS method for initiate endpoint (CORS)
resource "aws_api_gateway_method" "initiate_options" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.initiate.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "initiate_options_200" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.initiate.id
  http_method = aws_api_gateway_method.initiate_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

resource "aws_api_gateway_integration" "initiate_options" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.initiate.id
  http_method = aws_api_gateway_method.initiate_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "initiate_options" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.initiate.id
  http_method = aws_api_gateway_method.initiate_options.http_method
  status_code = aws_api_gateway_method_response.initiate_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods"     = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"      = "'*'" # Replace with your specific domain in production
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }
}


resource "aws_api_gateway_integration" "initiate_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.auth_api.id
  resource_id             = aws_api_gateway_resource.initiate.id
  http_method             = aws_api_gateway_method.initiate_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.initiate_auth.invoke_arn
}

# Add integration responses for actual endpoints
resource "aws_api_gateway_integration_response" "initiate_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.initiate.id
  http_method = aws_api_gateway_method.initiate_post.http_method
  status_code = aws_api_gateway_method_response.initiate_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = "'*'" # Replace with your specific domain in production
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods"     = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }

  depends_on = [
    aws_api_gateway_integration.initiate_lambda
  ]
}

# Verify OTP endpoint
resource "aws_api_gateway_resource" "verify" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "verify"
}

resource "aws_api_gateway_method" "verify_post" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.verify.id
  http_method   = "POST"
  authorization = "NONE"


  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

resource "aws_api_gateway_method_response" "verify_200" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.verify.id
  http_method = aws_api_gateway_method.verify_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}


# Add OPTIONS method for verify endpoint (CORS)
resource "aws_api_gateway_method" "verify_options" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.verify.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "verify_options_200" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.verify.id
  http_method = aws_api_gateway_method.verify_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

resource "aws_api_gateway_integration" "verify_options" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.verify.id
  http_method = aws_api_gateway_method.verify_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "verify_options" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.verify.id
  http_method = aws_api_gateway_method.verify_options.http_method
  status_code = aws_api_gateway_method_response.verify_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods"     = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"      = "'*'" # Replace with your specific domain in production
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }
}


resource "aws_api_gateway_integration" "verify_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.auth_api.id
  resource_id             = aws_api_gateway_resource.verify.id
  http_method             = aws_api_gateway_method.verify_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.verify_otp.invoke_arn
}

resource "aws_api_gateway_integration_response" "verify_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.verify.id
  http_method = aws_api_gateway_method.verify_post.http_method
  status_code = aws_api_gateway_method_response.verify_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = "'*'" # Replace with your specific domain in production
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods"     = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }

  depends_on = [
    aws_api_gateway_integration.verify_lambda
  ]
}

# CORS Configuration
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}


# Deployment
resource "aws_api_gateway_deployment" "auth_api" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.auth.id,
      aws_api_gateway_resource.initiate.id,
      aws_api_gateway_resource.verify.id,
      aws_api_gateway_method.initiate_post.id,
      aws_api_gateway_method.verify_post.id,
      aws_api_gateway_integration.initiate_lambda.id,
      aws_api_gateway_integration.verify_lambda.id,
      aws_api_gateway_method.initiate_options.id,
      aws_api_gateway_integration.initiate_options.id,
      aws_api_gateway_method.verify_options.id,
      aws_api_gateway_integration.verify_options.id,
      aws_api_gateway_method.options_method.id,
      aws_api_gateway_integration.options_integration.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.initiate_lambda,
    aws_api_gateway_integration.verify_lambda,
    aws_api_gateway_integration.initiate_options,
    aws_api_gateway_integration.verify_options,
    aws_api_gateway_method.initiate_options,
    aws_api_gateway_method.verify_options,
    aws_api_gateway_method.initiate_post,
    aws_api_gateway_method.verify_post,
    aws_api_gateway_resource.auth,
    aws_api_gateway_resource.initiate,
    aws_api_gateway_resource.verify
  ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "dev" {
  deployment_id        = aws_api_gateway_deployment.auth_api.id
  rest_api_id          = aws_api_gateway_rest_api.auth_api.id
  stage_name           = "dev"
  xray_tracing_enabled = true

  # Add variables if needed
  variables = {
    "environment" = "dev"
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp               = "$context.identity.sourceIp"
      requestTime            = "$context.requestTime"
      protocol              = "$context.protocol"
      httpMethod            = "$context.httpMethod"
      resourcePath          = "$context.resourcePath"
      routeKey              = "$context.routeKey"
      status                = "$context.status"
      responseLength        = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

  depends_on = [aws_api_gateway_account.main]
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${aws_api_gateway_rest_api.auth_api.name}"
  retention_in_days = 7
}


resource "aws_api_gateway_method_response" "error_responses" {
  for_each    = toset(["400", "401", "403", "500"])
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.verify.id
  http_method = aws_api_gateway_method.verify_post.http_method
  status_code = each.key

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "initiate_error_responses" {
  for_each    = toset(["400", "401", "403", "500"])
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.initiate.id
  http_method = aws_api_gateway_method.initiate_post.http_method
  status_code = each.key

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}


 # IAM role for API Gateway CloudWatch logging
resource "aws_iam_role" "cloudwatch" {
  name = "api-gateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# Attach CloudWatch policy to the role
resource "aws_iam_role_policy" "cloudwatch" {
  name = "api-gateway-cloudwatch-policy"
  role = aws_iam_role.cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}




