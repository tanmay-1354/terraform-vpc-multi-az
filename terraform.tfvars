# AWS Configuration
aws_region = "ap-south-1"
environment = "dev"

# VPC Configuration
vpc_cidr     = "10.0.0.0/16"
project_name = "main"

# Subnet Configuration
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# Availability Zones
availability_zones = ["ap-south-1a", "ap-south-1b"]

# RDS Configuration
database_engine              = "mysql"
database_name                = "appdb"
database_master_username     = "admin"
database_allocated_storage   = 20
database_instance_class      = "t3.micro"
