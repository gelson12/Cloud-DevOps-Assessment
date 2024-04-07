provider "aws" {
  region                      = var.aws_region
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_force_path_style         = true
  endpoints {
    ec2        = "http://localhost:4566"
    rds        = "http://localhost:4566"
    elasticloadbalancing = "http://localhost:4566"
  }
}

resource "aws_ec2_instance" "app_server" {
  ami           = "ami-123456" # Use a mock AMI ID
  instance_type = "t2.micro"
  # Ensure you have a valid security group allowing HTTP traffic
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  # Assuming you're in a subnet that's routable
  subnet_id = var.subnet_id
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow inbound HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "app_db" {
  engine               = "postgres"
  instance_class       = "db.t2.micro"
  allocated_storage    = 20
  username             = var.db_username
  password             = var.db_password
}

resource "aws_elb" "app_load_balancer" {
  name               = "app-load-balancer"
  availability_zones = ["us-east-1a"]
  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  instances                   = [aws_ec2_instance.app_server.id]
}