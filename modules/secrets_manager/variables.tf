variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "secret_description" {
  description = "Description for the secret"
  type        = string
  default     = "RDS database credentials"
}
