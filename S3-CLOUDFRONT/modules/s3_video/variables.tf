variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for videos"
}

variable "website_bucket_arn" {
  type        = string
  description = "ARN of the website bucket"
}


variable "tags" {
  type        = map(string)
  description = "Tags to be applied to all resources"
  default     = {}
}
