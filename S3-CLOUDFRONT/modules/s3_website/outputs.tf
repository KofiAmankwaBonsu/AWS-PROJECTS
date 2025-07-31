output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
  description = "Website endpoint URL"
}

output "bucket_arn" {
  value       = aws_s3_bucket.website.arn
  description = "Website bucket ARN"
}

output "bucket_id" {
  value       = aws_s3_bucket.website.id
  description = "Website bucket name"
}

output "origin_access_control_id" {
  description = "The ID of the CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.website.id
}

output "bucket_name" {
  value       = aws_s3_bucket.website.id
  description = "Website bucket name"
}

