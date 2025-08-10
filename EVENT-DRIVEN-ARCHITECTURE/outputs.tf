output "source_bucket" {
  value = aws_s3_bucket.source_bucket.id
}

output "destination_bucket" {
  value = aws_s3_bucket.destination_bucket.id
}

output "queue_url" {
  value = aws_sqs_queue.file_queue.url
}

output "source_bucket_arn" {
  value = aws_s3_bucket.source_bucket.arn
}

output "destination_bucket_arn" {
  value = aws_s3_bucket.destination_bucket.arn
}