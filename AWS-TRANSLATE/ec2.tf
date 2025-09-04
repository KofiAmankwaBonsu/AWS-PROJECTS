# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}a"
  default_for_az    = true
}

# Security group for EC2
resource "aws_security_group" "web_sg" {
  name_prefix = "translate-web-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #restrict in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Generate SSH key pair
resource "tls_private_key" "web_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# AWS key pair using generated public key
resource "aws_key_pair" "web_key" {
  key_name   = "translate-web-key"
  public_key = tls_private_key.web_key.public_key_openssh
}

# EC2 instance
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.web_key.key_name

  user_data = base64encode(file("${path.module}/user_data.sh"))

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.web_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "file" {
    content = templatefile("${path.module}/index.html", {
      api_endpoint = "${aws_api_gateway_stage.translate_stage.invoke_url}/translate"
    })
    destination = "/tmp/index.html"
  }

  provisioner "file" {
    source      = "${path.module}/styles.css"
    destination  = "/tmp/styles.css"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 2; done",
      "sudo systemctl status httpd || sudo systemctl start httpd",
      "sudo cp /tmp/index.html /var/www/html/",
      "sudo cp /tmp/styles.css /var/www/html/",
      "sudo chown -R apache:apache /var/www/html",
      "sudo chmod -R 755 /var/www/html"
    ]
  }

  tags = {
    Name = "translate-web-server"
  }
}