output "video_bucket_domain" {
  value       = aws_s3_bucket.video.bucket_regional_domain_name
  description = "Video bucket domain name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.video.arn
  description = "Video bucket ARN"
}

output "bucket_name" {
  value       = aws_s3_bucket.video.id
  description = "Video bucket name"
}

output "bucket_id" {
  value = aws_s3_bucket.video.id
}

output "origin_access_control_id" {
  description = "The ID of the CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.video.id

}


