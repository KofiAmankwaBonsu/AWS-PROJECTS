variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "website_bucket_name" {
  type        = string
  description = "Name of the bucket for website hosting"
}

variable "video_bucket_name" {
  type        = string
  description = "Name of the bucket for video storage"
}

variable "content_types" {
  type        = map(string)
  description = "Map of file extensions to content types"
  default = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "ico"  = "image/x-icon"
    "mp4"  = "video/mp4"
    "webm" = "video/webm"
    "ogg"  = "video/ogg"
    "mov"  = "video/quicktime"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to all resources"
  default     = {}
}

variable "website_bucket_arn" {
  type        = string
  description = "ARN of the website bucket"
}

variable "video_bucket_domain" {
  type        = string
  description = "Domain name of the video bucket"
}

variable "website_endpoint" {
  type        = string
  description = "Website endpoint"
}
