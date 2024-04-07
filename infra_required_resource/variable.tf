# Variables declaration
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be created"
}

variable "vpc_id" {
  description = "VPC ID for the security group"
}

variable "db_username" {
  description = "Username for the database"
}

variable "db_password" {
  description = "Password for the database"
}