# Terraform VPC with Multi-AZ Subnets

This Terraform configuration creates an AWS VPC with multi-availability zone subnet architecture in the ap-south-1 (Mumbai) region.

## Architecture

- **VPC**: 10.0.0.0/16
- **Public Subnets**: 2 subnets across ap-south-1a and ap-south-1b with internet access
- **Private Subnets**: 2 subnets across ap-south-1a and ap-south-1b without direct internet access
- **Internet Gateway**: Attached to VPC for public subnet internet routing
- **Route Tables**: Separate route tables for public and private subnets

## Project Structure

```
.
├── main.tf                 # Root module - instantiates VPC module
├── variables.tf            # Root module variable definitions
├── outputs.tf              # Root module outputs
├── provider.tf             # AWS provider configuration
├── terraform.tf            # Terraform and provider version requirements
├── terraform.tfvars        # Variable values (customize this file)
└── modules/
    └── vpc/
        ├── main.tf         # VPC and Internet Gateway resources
        ├── subnets.tf      # Public and private subnet resources
        ├── route_tables.tf # Route tables and associations
        ├── variables.tf    # Module variable definitions
        └── outputs.tf      # Module outputs
```

## Prerequisites

1. **Terraform**: Install Terraform >= 1.0 from [terraform.io](https://www.terraform.io/downloads)
2. **AWS CLI**: Install and configure AWS CLI with your credentials
3. **AWS Credentials**: Configure your AWS credentials using one of these methods:
   - AWS CLI: `aws configure`
   - Environment variables: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
   - IAM role (if running on EC2)

## Required AWS Permissions

Your AWS credentials need the following permissions:
- `ec2:CreateVpc`
- `ec2:CreateSubnet`
- `ec2:CreateInternetGateway`
- `ec2:AttachInternetGateway`
- `ec2:CreateRouteTable`
- `ec2:CreateRoute`
- `ec2:AssociateRouteTable`
- `ec2:CreateTags`
- `ec2:Describe*`

## Usage

### 1. Customize Configuration

Edit `terraform.tfvars` to customize your VPC configuration:

```hcl
# AWS Configuration
aws_region = "ap-south-1"

# VPC Configuration
vpc_cidr     = "10.0.0.0/16"
project_name = "main"

# Subnet Configuration
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# Availability Zones
availability_zones = ["ap-south-1a", "ap-south-1b"]
```

### 2. Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider and initializes the working directory.

### 3. Validate Configuration

```bash
terraform validate
```

This checks the syntax and configuration for errors.

### 4. Plan Infrastructure

```bash
terraform plan
```

This shows what resources will be created without actually creating them.

### 5. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the infrastructure.

Or use auto-approve to skip the confirmation:

```bash
terraform apply -auto-approve
```

### 6. View Outputs

After successful apply, view the created resource IDs:

```bash
terraform output
```

Example output:
```
vpc_id = "vpc-0123456789abcdef0"
public_subnet_ids = [
  "subnet-0123456789abcdef0",
  "subnet-0123456789abcdef1",
]
private_subnet_ids = [
  "subnet-0123456789abcdef2",
  "subnet-0123456789abcdef3",
]
internet_gateway_id = "igw-0123456789abcdef0"
```

## Verification

### Verify VPC Creation

```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=main-vpc" --region ap-south-1
```

### Verify Subnets

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>" --region ap-south-1
```

### Verify Route Tables

```bash
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>" --region ap-south-1
```

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

Type `yes` when prompted, or use auto-approve:

```bash
terraform destroy -auto-approve
```

## Customization

### Change Region

Edit `terraform.tfvars`:
```hcl
aws_region = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]
```

### Change CIDR Blocks

Edit `terraform.tfvars`:
```hcl
vpc_cidr = "172.16.0.0/16"
public_subnet_cidrs  = ["172.16.1.0/24", "172.16.2.0/24"]
private_subnet_cidrs = ["172.16.3.0/24", "172.16.4.0/24"]
```

### Add More Subnets

Edit `terraform.tfvars` to add more availability zones and CIDR blocks:
```hcl
availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.5.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24", "10.0.6.0/24"]
```

## Troubleshooting

### Error: Invalid CIDR Block

Ensure subnet CIDR blocks are within the VPC CIDR range and don't overlap.

### Error: Invalid Availability Zone

Verify the availability zones exist in your target region:
```bash
aws ec2 describe-availability-zones --region ap-south-1
```

### Error: Insufficient Permissions

Ensure your AWS credentials have the required IAM permissions listed above.

### Error: VPC Limit Exceeded

Check your VPC quota and request an increase if needed:
```bash
aws service-quotas get-service-quota --service-code vpc --quota-code L-F678F1CE --region ap-south-1
```

## License

This project is provided as-is for educational and production use.
