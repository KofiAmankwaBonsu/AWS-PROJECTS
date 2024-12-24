output "website_bucket_name" {
  value       = module.website_bucket.bucket_name
  description = "The name of the website bucket"
}

output "video_bucket_name" {
  value       = module.video_bucket.bucket_name
  description = "The name of the video bucket"
}

output "website_endpoint" {
  value       = module.website_bucket.website_endpoint
  description = "Website endpoint URL"
}

output "video_bucket_domain" {
  value       = module.video_bucket.video_bucket_domain
  description = "Video bucket domain name"
}

output "random_suffix" {
  value       = random_string.bucket_suffix.result
  description = "Random suffix generated for bucket names"
}
