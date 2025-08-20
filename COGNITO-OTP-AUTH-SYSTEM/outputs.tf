output "api_gateway_url" {
  value = aws_api_gateway_stage.dev.invoke_url
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.auth_pool.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.auth_client.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.otp_table.name
}
