# Output the instance ID for SSM connection
output "instance_id" {
  value = aws_instance.private.id
}