# How to Retrieve RDS Credentials from Secrets Manager

After deploying the infrastructure, your RDS credentials are securely stored in AWS Secrets Manager. Here's how to retrieve them.

## Method 1: Using Terraform Output (Easiest)

After running `terraform apply`, view the credentials directly:

```bash
# View all outputs
terraform output

# View only the password (sensitive - won't display by default)
terraform output rds_password

# View username
terraform output rds_username

# View secret name
terraform output secrets_manager_secret_name
```

Example output:
```
rds_username = "admin"
secrets_manager_secret_name = "rds/dev/appdb/credentials"
```

## Method 2: Using AWS CLI

### Get the Secret Value

```bash
# Replace with your secret name
aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query SecretString \
  --output text
```

Output:
```json
{"username":"admin","password":"xK9mP2qL8vN5rT3wQ1sU6yZ4aB7cD0eF"}
```

### Parse JSON to Get Individual Values

```bash
# Get only the password
aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query 'SecretString' \
  --output text | jq -r '.password'

# Get only the username
aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query 'SecretString' \
  --output text | jq -r '.username'
```

## Method 3: Using AWS Console

1. Go to **AWS Secrets Manager** in the AWS Console
2. Search for `rds/dev/appdb/credentials`
3. Click on the secret name
4. Scroll down to **Secret value**
5. Click **Retrieve secret value**
6. View the JSON with username and password

## Method 4: Using Python Script

Create a script to retrieve credentials programmatically:

```python
import boto3
import json

def get_rds_credentials(secret_name, region_name='ap-south-1'):
    """
    Retrieve RDS credentials from Secrets Manager
    """
    client = boto3.client('secretsmanager', region_name=region_name)
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        
        return {
            'username': secret['username'],
            'password': secret['password']
        }
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return None

# Usage
credentials = get_rds_credentials('rds/dev/appdb/credentials')
if credentials:
    print(f"Username: {credentials['username']}")
    print(f"Password: {credentials['password']}")
```

## Method 5: Using Bash Script

Create a reusable bash script:

```bash
#!/bin/bash

# retrieve_rds_credentials.sh

SECRET_NAME="${1:-rds/dev/appdb/credentials}"
REGION="${2:-ap-south-1}"

echo "Retrieving credentials for: $SECRET_NAME"
echo "Region: $REGION"
echo ""

SECRET_VALUE=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$REGION" \
  --query 'SecretString' \
  --output text)

USERNAME=$(echo "$SECRET_VALUE" | jq -r '.username')
PASSWORD=$(echo "$SECRET_VALUE" | jq -r '.password')

echo "Username: $USERNAME"
echo "Password: $PASSWORD"
```

Usage:
```bash
chmod +x retrieve_rds_credentials.sh
./retrieve_rds_credentials.sh rds/dev/appdb/credentials ap-south-1
```

## Method 6: Connect to RDS Using Retrieved Credentials

### For MySQL

```bash
# Get credentials
SECRET=$(aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query 'SecretString' \
  --output text)

USERNAME=$(echo "$SECRET" | jq -r '.username')
PASSWORD=$(echo "$SECRET" | jq -r '.password')
ENDPOINT=$(terraform output -raw rds_address)
DATABASE=$(terraform output -raw rds_database_name)

# Connect to MySQL
mysql -h "$ENDPOINT" -u "$USERNAME" -p"$PASSWORD" "$DATABASE"
```

### For PostgreSQL

```bash
# Get credentials
SECRET=$(aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query 'SecretString' \
  --output text)

USERNAME=$(echo "$SECRET" | jq -r '.username')
PASSWORD=$(echo "$SECRET" | jq -r '.password')
ENDPOINT=$(terraform output -raw rds_address)
DATABASE=$(terraform output -raw rds_database_name)

# Connect to PostgreSQL
PGPASSWORD="$PASSWORD" psql -h "$ENDPOINT" -U "$USERNAME" -d "$DATABASE"
```

## Understanding the Secret Structure

The secret stored in Secrets Manager is a JSON object:

```json
{
  "username": "admin",
  "password": "xK9mP2qL8vN5rT3wQ1sU6yZ4aB7cD0eF"
}
```

**Key Points:**
- `username`: Database master username (default: "admin")
- `password`: Randomly generated 16-character password with special characters
- The password is generated on first deployment
- The password persists across subsequent deployments (no rotation)

## Secret Naming Convention

Secrets are stored with this naming pattern:

```
rds/{environment}/{database_name}/credentials
```

Examples:
- `rds/dev/appdb/credentials` - Development environment
- `rds/staging/appdb/credentials` - Staging environment
- `rds/prod/appdb/credentials` - Production environment

## Security Best Practices

1. **Never hardcode credentials** in your code
2. **Use IAM roles** for EC2 instances to access Secrets Manager
3. **Rotate credentials manually** if needed (delete secret version and re-run terraform)
4. **Audit access** using CloudTrail
5. **Encrypt secrets** using AWS KMS (default)
6. **Restrict IAM permissions** to only necessary services

## IAM Permissions Required

To retrieve credentials, your AWS user/role needs these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:ap-south-1:ACCOUNT_ID:secret:rds/dev/appdb/credentials-*"
    }
  ]
}
```

## Troubleshooting

### Error: "ResourceNotFoundException"
- Secret doesn't exist yet
- Run `terraform apply` to create it
- Verify the secret name matches

### Error: "AccessDeniedException"
- Your AWS credentials don't have permission
- Add the IAM permissions above
- Check your AWS credentials are configured

### Error: "jq: command not found"
- Install jq: `brew install jq` (macOS) or `apt-get install jq` (Linux)
- Or use Python/other tools to parse JSON

### Password Not Displaying in Terraform Output
- This is intentional (marked as sensitive)
- Use AWS CLI or console to view
- Or use `terraform output -raw rds_password` (not recommended)

## Credential Rotation

To manually rotate credentials:

1. Delete the current secret version:
```bash
aws secretsmanager delete-secret \
  --secret-id rds/dev/appdb/credentials \
  --force-delete-without-recovery \
  --region ap-south-1
```

2. Re-run Terraform to generate new credentials:
```bash
terraform apply
```

3. Update your application with new credentials

**Note:** Automatic rotation is disabled to prevent application disruption.

## Application Integration

### Environment Variables

```bash
# Set environment variables from Secrets Manager
export DB_USERNAME=$(aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query 'SecretString' \
  --output text | jq -r '.username')

export DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id rds/dev/appdb/credentials \
  --region ap-south-1 \
  --query 'SecretString' \
  --output text | jq -r '.password')

export DB_HOST=$(terraform output -raw rds_address)
export DB_PORT=$(terraform output -raw rds_port)
export DB_NAME=$(terraform output -raw rds_database_name)
```

### Docker Compose

```yaml
version: '3.8'
services:
  app:
    image: myapp:latest
    environment:
      DB_HOST: ${DB_HOST}
      DB_PORT: ${DB_PORT}
      DB_NAME: ${DB_NAME}
      DB_USERNAME: ${DB_USERNAME}
      DB_PASSWORD: ${DB_PASSWORD}
```

### Kubernetes Secret

```bash
# Create Kubernetes secret from Secrets Manager
kubectl create secret generic rds-credentials \
  --from-literal=username=$(aws secretsmanager get-secret-value \
    --secret-id rds/dev/appdb/credentials \
    --region ap-south-1 \
    --query 'SecretString' \
    --output text | jq -r '.username') \
  --from-literal=password=$(aws secretsmanager get-secret-value \
    --secret-id rds/dev/appdb/credentials \
    --region ap-south-1 \
    --query 'SecretString' \
    --output text | jq -r '.password')
```

## Summary

| Method | Use Case | Complexity |
|--------|----------|-----------|
| Terraform Output | Quick lookup | Easy |
| AWS CLI | Scripting | Medium |
| AWS Console | Manual viewing | Easy |
| Python Script | Application integration | Medium |
| Bash Script | Automation | Medium |
| Direct Connection | Database access | Medium |

Choose the method that best fits your workflow!
