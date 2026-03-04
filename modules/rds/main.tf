# Create DB Subnet Group for multi-AZ deployment
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# Create Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# Ingress rule for MySQL (port 3306)
resource "aws_security_group_rule" "rds_mysql_ingress" {
  count = var.engine == "mysql" ? 1 : 0

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]  # VPC CIDR
  security_group_id = aws_security_group.rds.id
}

# Ingress rule for PostgreSQL (port 5432)
resource "aws_security_group_rule" "rds_postgres_ingress" {
  count = var.engine == "postgres" ? 1 : 0

  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]  # VPC CIDR
  security_group_id = aws_security_group.rds.id
}

# Egress rule (allow all outbound traffic)
resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}

# Create RDS Database Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-${var.database_name}"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  allocated_storage = var.allocated_storage
  storage_type      = "gp2"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Backup and maintenance
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Performance and availability
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  apply_immediately      = true
  deletion_protection    = false

  # Monitoring
  enabled_cloudwatch_logs_exports = var.engine == "mysql" ? ["error", "general", "slowquery"] : ["postgresql"]

  tags = {
    Name        = "${var.environment}-${var.database_name}"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [password]
  }

  depends_on = [aws_db_subnet_group.main]
}
