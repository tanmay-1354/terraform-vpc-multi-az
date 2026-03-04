# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Create Secrets Manager secret container
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "rds/${var.environment}/${var.database_name}/credentials"
  description             = var.secret_description
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.environment}-${var.database_name}-credentials"
    Environment = var.environment
  }
}

# Store credentials in Secrets Manager
# On first deployment: creates new secret with generated password
# On subsequent deployments: ignores changes to prevent credential rotation
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.db_password.result
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Data source to retrieve existing credentials if secret already exists
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  depends_on = [aws_secretsmanager_secret_version.db_credentials]
}

# Local value to parse credentials
locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}
