output "requester_instance_public_ip" {
  description = "Public IP of the requester instance"
  value       = module.requester_instance.public_ip
}

output "accepter_instance_public_ip" {
  description = "Public IP of the accepter instance"
  value       = module.accepter_instance.public_ip
}

output "requester_instance_private_ip" {
  description = "Private IP of the requester instance"
  value       = module.requester_instance.private_ip
}

output "accepter_instance_private_ip" {
  description = "Private IP of the accepter instance"
  value       = module.accepter_instance.private_ip
}
