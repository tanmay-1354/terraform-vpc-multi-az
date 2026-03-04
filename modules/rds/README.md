# RDS Module

This module creates an AWS RDS database instance with multi-AZ deployment in private subnets.

## Features

- **Multi-AZ Deployment**: High availability across availability zones
- **Private Subnet Deployment**: Database is not publicly accessible
- **Flexible Engine Support**: MySQL or PostgreSQL
- **Minimal Instance Type**: t3.micro for cost efficiency
- **Security Group Management**: Automatic port configuration based on engine
- **CloudWatch Logs**: Enabled for monitoring and debugging
- **Automated Backups**: 7-day retention with daily backups

## Usage

```hcl
module "rds" {
  source = "./modules/rds"

  environment              = "dev"
  database_name            = "appdb"
  engine                   = "mysql"
  instance_class           = "t3.micro"
  allocated_storage        = 20
  master_username          = "admin"
  master_password          = "your-secure-password"
  vpc_id                   = "vpc-xxxxx"
  private_subnet_ids       = ["subnet-xxxxx", "subnet-yyyyy"]
  allowed_security_group_ids = []
}
```

## Input Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment` | string | - | Environment name (dev, staging, prod) |
| `database_name` | string | - | Name of the database |
| `engine` | string | "mysql" | Database engine (mysql or postgres) |
| `engine_version` | string | "8.0" | Database engine version |
| `instance_class` | string | "t3.micro" | RDS instance class |
| `allocated_storage` | number | 20 | Allocated storage in GB (minimum 20) |
| `master_username` | string | "admin" | Master username |
| `master_password` | string | - | Master password (sensitive) |
| `vpc_id` | string | - | VPC ID for RDS deployment |
| `private_subnet_ids` | list(string) | - | Private subnet IDs for multi-AZ |
| `allowed_security_group_ids` | list(string) | [] | Security groups allowed to access RDS |

## Output Values

| Output | Description |
|--------|-------------|
| `db_endpoint` | RDS database endpoint (hostname:port) |
| `db_address` | RDS database address (hostname only) |
| `db_port` | RDS database port |
| `db_name` | RDS database name |
| `db_security_group_id` | Security group ID for RDS |
| `db_subnet_group_name` | DB subnet group name |
| `db_instance_id` | RDS instance identifier |

## Security

- Database is deployed in private subnets (no public access)
- Security group restricts access to VPC CIDR only
- Port 3306 for MySQL, 5432 for PostgreSQL
- Credentials managed through Secrets Manager module
- Automated backups enabled with 7-day retention

## Monitoring

CloudWatch Logs are enabled for:
- **MySQL**: error, general, slowquery logs
- **PostgreSQL**: postgresql logs

## Backup and Recovery

- Automated backups: 7-day retention
- Backup window: 03:00-04:00 UTC
- Maintenance window: Monday 04:00-05:00 UTC
- Multi-AZ failover: Automatic

## Cost Optimization

- t3.micro instance type for minimal cost
- 20 GB storage (minimum recommended)
- gp2 storage type (general purpose)
- No public accessibility (no data transfer costs)

## Notes

- Password is managed by Secrets Manager module
- `skip_final_snapshot = true` for non-production environments
- `apply_immediately = true` for faster updates
- `deletion_protection = false` for easy cleanup in dev/test
