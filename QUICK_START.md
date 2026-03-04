# Quick Start Guide

Get your AWS infrastructure up and running in 5 minutes!

## Prerequisites

```bash
# Check Terraform is installed
terraform --version

# Check AWS CLI is installed
aws --version

# Configure AWS credentials
aws configure
```

## Step 1: Clone Repository

```bash
git clone https://github.com/tanmay-1354/terraform-vpc-multi-az.git
cd terraform-vpc-multi-az
```

## Step 2: Customize Configuration (Optional)

Edit `terraform.tfvars` to customize:

```hcl
# Change region if needed
aws_region = "ap-south-1"

# Change environment name
environment = "dev"

# Change database engine
database_engine = "mysql"  # or "postgres"

# Change database name
database_name = "appdb"

# Change instance type (if needed)
database_instance_class = "t3.micro"
```

## Step 3: Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider and initializes the working directory.

## Step 4: Review Plan

```bash
terraform plan
```

Review the resources that will be created. Look for:
- 1 VPC
- 4 Subnets (2 public, 2 private)
- 1 Internet Gateway
- 2 Route Tables
- 1 RDS Instance
- 1 Secrets Manager Secret

## Step 5: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. This takes about 5-10 minutes.

## Step 6: Get Outputs

```bash
terraform output
```

You'll see:
- VPC ID
- Subnet IDs
- RDS endpoint
- Secrets Manager secret name

## Step 7: Retrieve Database Credentials

### Option A: Using Terraform (Easiest)

```bash
# Get username
terraform output rds_username

# Get password (won't display - use AWS CLI instead)
aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query 'SecretString' \
  --output text | jq -r '.password'
```

### Option B: Using AWS Console

1. Go to AWS Secrets Manager
2. Search for `rds/dev/appdb/credentials`
3. Click on it
4. Click "Retrieve secret value"
5. Copy username and password

## Step 8: Connect to Database

### For MySQL

```bash
# Get connection details
ENDPOINT=$(terraform output -raw rds_address)
USERNAME=$(terraform output -raw rds_username)
DATABASE=$(terraform output -raw rds_database_name)

# Connect
mysql -h $ENDPOINT -u $USERNAME -p $DATABASE
```

### For PostgreSQL

```bash
# Get connection details
ENDPOINT=$(terraform output -raw rds_address)
USERNAME=$(terraform output -raw rds_username)
DATABASE=$(terraform output -raw rds_database_name)

# Connect
psql -h $ENDPOINT -U $USERNAME -d $DATABASE
```

## Verify Deployment

### Check VPC

```bash
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=main-vpc" \
  --region ap-south-1
```

### Check Subnets

```bash
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=<vpc-id>" \
  --region ap-south-1
```

### Check RDS Instance

```bash
aws rds describe-db-instances \
  --db-instance-identifier dev-appdb \
  --region ap-south-1
```

### Check Secrets Manager

```bash
aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1
```

## Common Commands

```bash
# View all outputs
terraform output

# View specific output
terraform output vpc_id

# Refresh state
terraform refresh

# Destroy infrastructure
terraform destroy

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate
```

## Troubleshooting

### Error: "terraform: command not found"
- Terraform not installed or not in PATH
- Restart your terminal after installation

### Error: "AWS credentials not found"
- Run `aws configure`
- Or set environment variables:
  ```bash
  export AWS_ACCESS_KEY_ID=your_key
  export AWS_SECRET_ACCESS_KEY=your_secret
  ```

### Error: "Insufficient permissions"
- Check your IAM permissions
- See README.md for required permissions

### Error: "VPC limit exceeded"
- Check your VPC quota
- Request increase in AWS Service Quotas

### RDS takes too long to create
- Normal! RDS Multi-AZ takes 5-10 minutes
- Be patient, don't interrupt

## Cost Estimate

**Monthly cost (ap-south-1):**
- RDS t3.micro: ~$30
- Storage: ~$2
- Secrets Manager: ~$0.40
- **Total: ~$32/month**

## Next Steps

1. ✅ Infrastructure deployed
2. ✅ Credentials retrieved
3. ✅ Database connected
4. Now: Deploy your application!

## Documentation

- **README.md** - Full documentation
- **ARCHITECTURE.md** - System design
- **RETRIEVE_CREDENTIALS.md** - Credential access methods
- **CHECKLIST.md** - Complete checklist
- **modules/vpc/README.md** - VPC module details
- **modules/rds/README.md** - RDS module details
- **modules/secrets_manager/README.md** - Secrets Manager details

## Support

For issues:
1. Check the troubleshooting section above
2. Review the relevant README.md file
3. Check AWS documentation
4. Open an issue on GitHub

## Cleanup

When done, destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted. This removes:
- VPC and subnets
- RDS instance
- Secrets Manager secret
- All associated resources

**Cost savings**: Stops all charges immediately!

---

**Ready to deploy?** Run: `terraform init && terraform plan && terraform apply`

**Questions?** Check the documentation files or GitHub issues.
