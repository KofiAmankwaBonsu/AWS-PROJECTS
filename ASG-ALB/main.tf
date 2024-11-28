# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
    Region      = data.aws_region.current.name

  }
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "demo_public_rtb"
    Terraform = "true"
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "demo_igw"
  }
}

# Create Security Group - Web Traffic
resource "aws_security_group" "vpc-web" {
  name        = "vpc-web-${terraform.workspace}"
  vpc_id      = aws_vpc.vpc.id
  description = "Web Traffic"
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-for-all"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.vpc-web.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  enable_deletion_protection = false

  tags = {
    Name        = "my-application-lb"
    Environment = "demo_environment"
  }
}

# Create a target group for the ALB
resource "aws_lb_target_group" "my_tg" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 60
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# Create a listener for the ALB
resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}

# Create a launch template
resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "my-launch-template"
  image_id      = "ami-063d43db0594b521b" # Replace with your desired AMI ID
  instance_type = "t2.micro"              # Replace with your desired instance type

  user_data = base64encode(file("${path.module}/user_data.sh"))


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.vpc-web.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "my-asg-instance"
    }
  }
}

# Create an Auto Scaling group
resource "aws_autoscaling_group" "my_asg" {
  name                = upper("my-asg")
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnets : subnet.id]
  target_group_arns   = [aws_lb_target_group.my_tg.arn]
  health_check_type   = "ELB"
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "my-asg-instance"
    propagate_at_launch = true
  }
}

# Create a target tracking scaling policy
resource "aws_autoscaling_policy" "target_tracking_policy" {
  name                   = "target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}

# Create CloudWatch alarm for scale-in
resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "cpu-utilization-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "600"
  statistic          = "Average"
  threshold          = "30"
  alarm_description  = "Scale in when CPU utilization is below 30%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name
  }
}

# Create scale-in policy
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown              = 300
  policy_type           = "SimpleScaling"
}

