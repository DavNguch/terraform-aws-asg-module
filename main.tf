data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]  # Use "amazon" for the official Amazon Linux image
}


#creating the launch template
resource "aws_launch_template" "lt" {
  name          = "${var.tier_name}-launch-template"
  description   = "My ${var.tier_name} launch template description"
  image_id      = data.aws_ami.latest_amazon_linux.id # The AMI ID for the instance
  instance_type = "t2.micro"     # Replace with your desired instance type
  key_name      = "keypair"  # Replace with your key pair name
  vpc_security_group_ids = [var.security_group_id]
  user_data     = filebase64(var.user_data_file)
  tags = merge(
    var.resource_tags,
    {
      Name = "${var.aws_region}-${var.resource_tags["Project"]}-${var.tier_name}-launch_template"
    }
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.resource_tags,
      {
        Name = "${var.aws_region}-${var.resource_tags["Project"]}-${var.tier_name}-EC2"
      }
    )
  }
  # Add additional instance configuration options as needed
  # e.g., user_data, block_device_mappings, security_groups, etc.
}


#Creating the autoscaling group
resource "aws_autoscaling_group" "asg" {
  name               = "${var.tier_name}-asg"
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnets_ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = 1
  }
}

#Attaching the auto_scaling_group to the target group
resource "aws_autoscaling_attachment" "att_asg_to_tg" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn = aws_lb_target_group.tg.id
}


#Creating a target group
resource "aws_lb_target_group" "tg" {
  name = "${var.tier_name}-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id 
  tags        = merge(
    var.resource_tags,
    {
      Name = "${var.aws_region}-${var.resource_tags["Project"]}-${var.tier_name}-sg"
    }
  )
}


#Security group for the load balancer
resource "aws_security_group" "alb_sg" {
    name = "${var.tier_name}-lb-security group"
    description = "Security group for the ${var.tier_name}-lb"
    vpc_id = var.vpc_id
    tags        = merge(
    var.resource_tags,
    {
      Name = "${var.aws_region}-${var.resource_tags["Project"]}-${var.tier_name}-sg"
    }
  )

  # Inbound rule for HTTP (port 80) only
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}


#Creating the load balancer
resource "aws_lb" "lb" {
  name               = "${var.tier_name}-lb"
  internal           = var.internal_lb
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnets_ids

  tags        = merge(
    var.resource_tags,
    {
      Name = "${var.aws_region}-${var.resource_tags["Project"]}-${var.tier_name}-alb"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn

  port = 80

  protocol = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

#creating the load balancer listener rule
resource "aws_lb_listener_rule" "web_listener_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}




