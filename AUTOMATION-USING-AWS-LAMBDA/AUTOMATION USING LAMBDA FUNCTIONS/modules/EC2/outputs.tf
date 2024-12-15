output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.my_server.id
}

output "instance_private_ip" {
  description = "Private IP of the created EC2 instance"
  value       = aws_instance.my_server.private_ip
}

output "instance_public_ip" {
  description = "Public IP of the created EC2 instance"
  value       = aws_instance.my_server.public_ip
}

output "security_group_id" {
  description = "ID of the security group attached to the instance"
  value       = aws_security_group.instance_sg.id
}
