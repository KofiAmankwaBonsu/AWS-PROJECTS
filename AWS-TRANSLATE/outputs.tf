output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "${aws_api_gateway_stage.translate_stage.invoke_url}/translate"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.translate_function.function_name
}

output "web_server_url" {
  description = "URL of the web server"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "web_server_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web_server.public_ip
}

output "ssh_private_key" {
  description = "Private key for SSH access (save to file)"
  value       = tls_private_key.web_key.private_key_pem
  sensitive   = true
}