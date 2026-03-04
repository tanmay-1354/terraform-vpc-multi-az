output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_username" {
  description = "Database username"
  value       = local.db_credentials.username
}

output "db_password" {
  description = "Database password (sensitive)"
  value       = local.db_credentials.password
  sensitive   = true
}
