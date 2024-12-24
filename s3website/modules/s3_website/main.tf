resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
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
  depends_on = [aws_s3_bucket_public_access_block.website]
}

resource "aws_s3_object" "index_html" {
  bucket        = aws_s3_bucket.website.id
  key           = "index.html"
  content_type  = "text/html"
  cache_control = "max-age=86400"
  content = templatefile("${var.static_files_path}/index.html.tftpl", {
    bucket_domain = var.video_bucket_domain
    videoKey      = "video.mp4"
  })
  etag = filemd5("${var.static_files_path}/index.html.tftpl")
}

resource "aws_s3_object" "static_files" {
  for_each = fileset(var.static_files_path, "**/*[^.tftpl]") # Excludes .tftpl files

  bucket        = aws_s3_bucket.website.id
  key           = each.value
  cache_control = "max-age=86400"
  source        = "${var.static_files_path}/${each.value}"

  content_type = lookup(
    var.content_types,
    reverse(split(".", each.value))[0],
    "application/octet-stream"
  )

  etag = filemd5("${var.static_files_path}/${each.value}")
}



