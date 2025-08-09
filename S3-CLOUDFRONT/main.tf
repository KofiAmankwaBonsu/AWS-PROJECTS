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
  website_bucket_arn = module.website_bucket.bucket_arn
  tags               = var.tags
}

resource "aws_s3_bucket_cors_configuration" "video_bucket" {
  bucket = module.video_bucket.bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", ]
    allowed_origins = ["https://${aws_cloudfront_distribution.video_distribution.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
  depends_on = [aws_cloudfront_distribution.video_distribution]
}

module "website_bucket" {
  source = "./modules/s3_website"

  bucket_name            = "${var.website_bucket_name}-${random_string.bucket_suffix.result}"
  video_bucket_domain    = module.video_bucket.video_bucket_domain
  cloudfront_domain_name = aws_cloudfront_distribution.video_distribution.domain_name
  static_files_path      = "${path.module}/static"
  content_types          = var.content_types
  tags                   = var.tags
}

resource "aws_cloudfront_distribution" "video_distribution" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name              = "${module.video_bucket.bucket_id}.s3.${var.aws_region}.amazonaws.com"
    origin_id                = "S3-Video"
    origin_access_control_id = module.video_bucket.origin_access_control_id
  }

  origin {
    domain_name              = "${module.website_bucket.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_id                = "S3-website"
    origin_access_control_id = module.website_bucket.origin_access_control_id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-website"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags

  ordered_cache_behavior {
    path_pattern     = "*.mp4" # Adjust pattern based on your video URL structure
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Video"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = module.website_bucket.bucket_id
  key          = "index.html"
  content_type = "text/html"

  content = templatefile("${path.module}/static/index.html.tftpl", {
    domain   = aws_cloudfront_distribution.video_distribution.domain_name
    videoKey = "video.mp4"
  })

  depends_on = [
    aws_cloudfront_distribution.video_distribution,
    module.website_bucket
  ]
}

resource "aws_s3_bucket_policy" "website" {
  bucket = module.website_bucket.bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = "*"
        Action   = "s3:GetObject"
        Resource = "${module.website_bucket.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.video_distribution.arn
          }
        }
      }
    ]
  })
  depends_on = [aws_cloudfront_distribution.video_distribution]
}


resource "aws_s3_bucket_policy" "video_bucket_policy" {
  bucket = module.video_bucket.bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.video_bucket.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.video_distribution.arn
          }
        }
      }
    ]
  })
  depends_on = [aws_cloudfront_distribution.video_distribution]
}

