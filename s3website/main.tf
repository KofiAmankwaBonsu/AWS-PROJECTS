provider "aws" {
  region = var.aws_region
}

provider "random" {}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

module "video_bucket" {
  source = "./modules/s3_video"

  bucket_name        = "${var.video_bucket_name}-${random_string.bucket_suffix.result}"
  allowed_origins    = ["http://${module.website_bucket.website_endpoint}/*"]
  website_bucket_arn = module.website_bucket.bucket_arn
  tags               = var.tags
}

module "website_bucket" {
  source = "./modules/s3_website"

  bucket_name         = "${var.website_bucket_name}-${random_string.bucket_suffix.result}"
  video_bucket_domain = module.video_bucket.video_bucket_domain
  static_files_path   = "${path.module}/static"
  content_types       = var.content_types
  tags                = var.tags
}