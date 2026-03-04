output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
}

output "rds_address" {
  description = "RDS database address (hostname only)"
  value       = module.rds.db_address
}

output "rds_port" {
  description = "RDS database port"
  value       = module.rds.db_port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_name
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.db_security_group_id
}

# Secrets Manager Outputs
output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = module.secrets_manager.secret_arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = module.secrets_manager.secret_name
}

output "rds_username" {
  description = "RDS master username"
  value       = module.secrets_manager.db_username
}

output "rds_password" {
  description = "RDS master password (stored in Secrets Manager)"
  value       = module.secrets_manager.db_password
  sensitive   = true
}
