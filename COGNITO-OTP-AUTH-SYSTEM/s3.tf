# Website bucket
resource "aws_s3_bucket" "website" {
  bucket = "mybucket646-${var.environment}-website"
}

# Enable website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Public access configuration
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for public read
resource "aws_s3_bucket_policy" "website" {
  bucket     = aws_s3_bucket.website.id
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      },
    ]
  })
}

# Upload website files with content type detection
locals {
  content_types = {
    "css"   = "text/css"
    "html"  = "text/html"
    "js"    = "application/javascript"
    "json"  = "application/json"
    "png"   = "image/png"
    "jpg"   = "image/jpeg"
    "jpeg"  = "image/jpeg"
    "gif"   = "image/gif"
    "svg"   = "image/svg+xml"
    "ico"   = "image/x-icon"
    "ttf"   = "font/ttf"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
    "eot"   = "application/vnd.ms-fontobject"
  }

  website_files = fileset("${path.module}/frontend", "**/*")
}

resource "aws_s3_object" "website_files" {
  for_each = local.website_files

  bucket = aws_s3_bucket.website.id
  key    = each.value
  source = "${path.module}/frontend/${each.value}"

  content_type = lookup(
    local.content_types,
    length(regexall("\\.[^.]+$", each.value)) > 0 ? trimprefix(regex("\\.[^.]+$", each.value), ".") : "txt",
    "application/octet-stream"
  )

  etag = filemd5("${path.module}/frontend/${each.value}")
}