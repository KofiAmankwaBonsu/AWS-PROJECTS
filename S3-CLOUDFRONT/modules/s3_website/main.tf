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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
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



