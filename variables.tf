variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
  default     = "main"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnet distribution"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# RDS Configuration
variable "database_engine" {
  description = "Database engine (mysql or postgres)"
  type        = string
  default     = "mysql"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "appdb"
}

variable "database_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "database_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "database_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "t3.micro"
}
