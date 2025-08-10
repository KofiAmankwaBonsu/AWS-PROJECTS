# Security Group for Private Instance
resource "aws_security_group" "private" {
  name        = "private-sg"
  description = "Security group for private instance"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Instance Profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# Private Instance
resource "aws_instance" "private" {
  ami                    = "ami-0f0744e293f17e887" # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "private-instance"
  }
}
