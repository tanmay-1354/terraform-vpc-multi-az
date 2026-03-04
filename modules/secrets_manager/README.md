# Secrets Manager Module

This module manages RDS database credentials in AWS Secrets Manager with intelligent credential persistence.

## Features

- **Automatic Password Generation**: Generates secure 16-character passwords on first deployment
- **Credential Persistence**: Credentials are stored and reused on subsequent deployments
- **No Rotation**: Prevents automatic credential rotation to maintain application stability
- **JSON Format**: Credentials stored as JSON for easy parsing
- **Secure Storage**: Secrets are encrypted at rest in AWS Secrets Manager
- **Recovery Window**: 7-day recovery window for accidental deletion

## Credential Management Logic

### First Deployment
1. Generates a random 16-character password
2. Creates a secret in AWS Secrets Manager
3. Stores credentials in JSON format: `{"username": "admin", "password": "..."}`

### Subsequent Deployments
1. Retrieves existing credentials from Secrets Manager
2. Uses `lifecycle.ignore_changes` to prevent credential rotation
3. Maintains the same credentials across deployments

## Usage

```hcl
module "secrets_manager" {
  source = "./modules/secrets_manager"

  environment        = "dev"
  database_name      = "appdb"
  master_username    = "admin"
  secret_description = "RDS database credentials"
}
```

## Input Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment` | string | - | Environment name (dev, staging, prod) |
| `database_name` | string | - | Name of the database |
| `master_username` | string | "admin" | Master username for the database |
| `secret_description` | string | "RDS database credentials" | Description for the secret |

## Output Values

| Output | Description |
|--------|-------------|
| `secret_arn` | ARN of the Secrets Manager secret |
| `secret_name` | Name of the Secrets Manager secret |
| `db_username` | Database username |
| `db_password` | Database password (sensitive, not displayed in logs) |

## Secret Naming Convention

Secrets are stored with the following naming pattern:
```
rds/{environment}/{database_name}/credentials
```

Example: `rds/dev/appdb/credentials`

## Retrieving Credentials

### Using AWS CLI
```bash
aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query SecretString \
  --output text | jq .
```

### Using AWS Console
1. Go to AWS Secrets Manager
2. Search for `rds/dev/appdb/credentials`
3. Click on the secret
4. View the secret value

### Using Terraform
```hcl
data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "rds/dev/appdb/credentials"
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}
```

## Security Best Practices

- Credentials are marked as sensitive in Terraform (not displayed in logs)
- Secrets are encrypted at rest in AWS Secrets Manager
- Access to secrets is controlled via IAM policies
- 7-day recovery window for accidental deletion
- No automatic rotation (prevents application disruption)

## Credential Rotation

To manually rotate credentials:

1. Delete the secret version in AWS Secrets Manager
2. Re-run `terraform apply` to generate new credentials
3. Update application configuration with new credentials

**Note**: Automatic rotation is disabled to prevent application authentication failures.

## Cost

AWS Secrets Manager pricing:
- $0.40 per secret per month
- $0.05 per 10,000 API calls

## Troubleshooting

### Secret Not Found
If you get "ResourceNotFoundException", the secret doesn't exist yet. Run `terraform apply` to create it.

### Credential Mismatch
If credentials don't match between Terraform and AWS:
1. Check the secret in AWS Secrets Manager console
2. Verify the secret name matches the pattern
3. Run `terraform refresh` to sync state

### Permission Denied
Ensure your AWS credentials have these permissions:
- `secretsmanager:CreateSecret`
- `secretsmanager:GetSecretValue`
- `secretsmanager:PutSecretValue`
