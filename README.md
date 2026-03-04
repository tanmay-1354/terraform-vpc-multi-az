# Terraform AWS Infrastructure

Complete Terraform configuration for AWS infrastructure including VPC, RDS, and Secrets Manager.

## Project Structure

```
.
├── main.tf                      # Root module - instantiates all modules
├── variables.tf                 # Root module variable definitions
├── outputs.tf                   # Root module outputs
├── provider.tf                  # AWS provider configuration
├── terraform.tf                 # Terraform and provider version requirements
├── terraform.tfvars             # Variable values (customize this file)
├── README.md                    # This file
├── .gitignore                   # Git ignore rules
└── modules/
    ├── vpc/                     # VPC module
    │   ├── main.tf              # VPC, IGW, and networking resources
    │   ├── subnets.tf           # Public and private subnets
    │   ├── route_tables.tf      # Route tables and associations
    │   ├── variables.tf         # Module variables
    │   ├── outputs.tf           # Module outputs
    │   └── README.md            # VPC module documentation
    ├── rds/                     # RDS module
    │   ├── main.tf              # RDS instance, security group, subnet group
    │   ├── variables.tf         # Module variables
    │   ├── outputs.tf           # Module outputs
    │   └── README.md            # RDS module documentation
    └── secrets_manager/         # Secrets Manager module
        ├── main.tf              # Secrets Manager resources
        ├── variables.tf         # Module variables
        ├── outputs.tf           # Module outputs
        └── README.md            # Secrets Manager module documentation
```

## Architecture Overview

- **VPC**: 10.0.0.0/16 with multi-AZ deployment
- **Public Subnets**: 2 subnets (ap-south-1a, ap-south-1b) with internet access
- **Private Subnets**: 2 subnets (ap-south-1a, ap-south-1b) for database tier
- **RDS Database**: MySQL/PostgreSQL on t3.micro in private subnets
- **Secrets Manager**: Secure credential storage with persistence

## Prerequisites

1. **Terraform**: >= 1.0
2. **AWS CLI**: Configured with credentials
3. **AWS Account**: With appropriate permissions

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/tanmay-1354/terraform-vpc-multi-az.git
cd terraform-vpc-multi-az
```

### 2. Customize Configuration

Edit `terraform.tfvars`:

```hcl
aws_region = "ap-south-1"
environment = "dev"
database_engine = "mysql"
database_name = "appdb"
```

### 3. Deploy Infrastructure

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### 4. View Outputs

```bash
terraform output
```

## Module Documentation

- **VPC Module**: `modules/vpc/README.md`
- **RDS Module**: `modules/rds/README.md`
- **Secrets Manager Module**: `modules/secrets_manager/README.md`

## Cleanup

```bash
terraform destroy
```

## Cost Estimation

**Monthly (dev environment):**
- RDS t3.micro: ~$30
- Secrets Manager: ~$0.40
- **Total: ~$30/month**

## Support

For issues, check module-specific README files or AWS documentation.

## License

This project is provided as-is for educational and production use.
