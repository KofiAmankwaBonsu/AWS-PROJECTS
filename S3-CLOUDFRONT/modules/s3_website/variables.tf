variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for website"
}

variable "static_files_path" {
  type        = string
  description = "Path to the directory containing static files"
}

variable "content_types" {
  type        = map(string)
  description = "Map of file extensions to content types"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to all resources"
  default     = {}
}

variable "video_bucket_domain" {
  type        = string
  description = "Domain name of the S3 bucket for video files"
}

variable "cloudfront_domain_name" {
  type        = string
  description = "The domain name of the CloudFront distribution"
}




