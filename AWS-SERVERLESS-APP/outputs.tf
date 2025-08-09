output "frontend_bucket_domain_name" {
  value = "http://${aws_s3_bucket.frontend.bucket_regional_domain_name}"
}

output "api_endpoint" {
  value = "${aws_apigatewayv2_api.api.api_endpoint}/${var.environment}"
}
