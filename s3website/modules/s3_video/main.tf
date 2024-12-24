resource "aws_s3_bucket" "video" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_cors_configuration" "video" {
  bucket = aws_s3_bucket.video.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 86400
  }
}

resource "aws_s3_bucket_public_access_block" "video" {
  bucket = aws_s3_bucket.video.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "video_bucket_policy" {
  bucket     = aws_s3_bucket.video.id
  depends_on = [aws_s3_bucket_public_access_block.video]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSpecificBucketAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.video.arn}/*"
        Condition = {
          StringLike = {
            "aws:Referer" : var.allowed_origins
          }
        }
      },
    ]
  })
}
