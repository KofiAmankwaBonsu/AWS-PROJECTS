module "vpc_requester" {
  source = "./modules/network"

  vpc_cidr           = var.requester_vpc_cidr
  vpc_name           = "requester-vpc"
  public_subnet_cidr = var.requester_subnet_cidr
  availability_zone  = var.availability_zones[0]
}

module "vpc_accepter" {
  source = "./modules/network"

  vpc_cidr           = var.accepter_vpc_cidr
  vpc_name           = "accepter-vpc"
  public_subnet_cidr = var.accepter_subnet_cidr
  availability_zone  = var.availability_zones[1]
}

module "vpc_peering" {
  source = "./modules/peering"

  vpc_id                   = module.vpc_requester.vpc_id
  peer_vpc_id              = module.vpc_accepter.vpc_id
  peering_name             = "vpc-peer"
  requester_route_table_id = module.vpc_requester.route_table_id
  accepter_route_table_id  = module.vpc_accepter.route_table_id
  requester_cidr           = var.requester_vpc_cidr
  accepter_cidr            = var.accepter_vpc_cidr
}

module "requester_instance" {
  source = "./modules/compute"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc_requester.public_subnet_id
  vpc_id        = module.vpc_requester.vpc_id
  instance_name = "requester-instance"
  key_name      = var.key_name
  peer_vpc_cidr = var.accepter_vpc_cidr
}

module "accepter_instance" {
  source = "./modules/compute"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc_accepter.public_subnet_id
  vpc_id        = module.vpc_accepter.vpc_id
  instance_name = "accepter-instance"
  key_name      = var.key_name
  peer_vpc_cidr = var.requester_vpc_cidr
}

# TLS provider block
provider "tls" {}

# Generate private key
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS key pair using the generated public key
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.key_pair.public_key_openssh

  # Optional: Add tags if needed
  tags = {
    Name = "generated-key-pair"
  }
}

# Optional: Save private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.key_pair.private_key_pem
  filename = "${var.key_name}.pem"

  # Set file permissions to be restrictive
  file_permission = "0600"
}
