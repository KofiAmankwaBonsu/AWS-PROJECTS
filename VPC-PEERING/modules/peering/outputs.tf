output "peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.id
}

output "peering_connection_status" {
  description = "Status of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.accept_status
}

output "requester_route_id" {
  description = "ID of the requester route"
  value       = aws_route.requester_route.id
}

output "accepter_route_id" {
  description = "ID of the accepter route"
  value       =  aws_route.accepter_route.id
}
