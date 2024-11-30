variable "vpc_id" {
  type        = string
  description = "ID of the requester VPC"
}

variable "peer_vpc_id" {
  type        = string
  description = "ID of the accepter VPC"
}

variable "peering_name" {
  type        = string
  description = "Name tag for the peering connection"
}

variable "same_account" {
  type        = bool
  description = "Whether the VPCs are in the same AWS account"
  default     = true
}

variable "requester_route_table_id" {
  type        = string
  description = "ID of the requester VPC route table"
}

variable "accepter_route_table_id" {
  type        = string
  description = "ID of the accepter VPC route table"
}

variable "requester_cidr" {
  type        = string
  description = "CIDR block of the requester VPC"
}

variable "accepter_cidr" {
  type        = string
  description = "CIDR block of the accepter VPC"
}
