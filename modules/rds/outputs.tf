output "db_endpoint" {
  description = "RDS database endpoint (hostname)"
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "RDS database address (hostname only)"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS database port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

output "db_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.id
}
