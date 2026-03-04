# AWS Infrastructure Architecture Diagram

## Complete System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   AWS Account (ap-south-1)                          │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌──────────────────────────────────────────────────────────────────────────────┐  │
│  │                         VPC (10.0.0.0/16)                                    │  │
│  │                                                                              │  │
│  │  ┌────────────────────────────────────────────────────────────────────────┐ │  │
│  │  │                    Internet Gateway (IGW)                              │ │  │
│  │  │                                                                        │ │  │
│  │  └────────────────────────────────────────────────────────────────────────┘ │  │
│  │                                    │                                         │  │
│  │                                    │ (0.0.0.0/0)                             │  │
│  │                                    ▼                                         │  │
│  │  ┌────────────────────────────────────────────────────────────────────────┐ │  │
│  │  │                    Public Route Table                                  │ │  │
│  │  │  Route: 0.0.0.0/0 → IGW                                               │ │  │
│  │  └────────────────────────────────────────────────────────────────────────┘ │  │
│  │                                    │                                         │  │
│  │         ┌──────────────────────────┴──────────────────────────────┐         │  │
│  │         │                                                         │         │  │
│  │         ▼                                                         ▼         │  │
│  │  ┌──────────────────────────────┐                    ┌──────────────────────┐ │  │
│  │  │  Public Subnet 1a            │                    │  Public Subnet 1b    │ │  │
│  │  │  CIDR: 10.0.1.0/24           │                    │  CIDR: 10.0.2.0/24   │ │  │
│  │  │  AZ: ap-south-1a             │                    │  AZ: ap-south-1b     │ │  │
│  │  │  Map Public IP: ✓            │                    │  Map Public IP: ✓    │ │  │
│  │  │                              │                    │                      │ │  │
│  │  │  Resources:                  │                    │  Resources:          │ │  │
│  │  │  - NAT Gateway (optional)    │                    │  - NAT Gateway       │ │  │
│  │  │  - Bastion Host (optional)   │                    │  - Load Balancer     │ │  │
│  │  └──────────────────────────────┘                    └──────────────────────┘ │  │
│  │                                                                              │  │
│  │  ┌────────────────────────────────────────────────────────────────────────┐ │  │
│  │  │                    Private Route Table                                 │ │  │
│  │  │  Route: 0.0.0.0/0 → NAT Gateway (optional)                            │ │  │
│  │  └────────────────────────────────────────────────────────────────────────┘ │  │
│  │                                    │                                         │  │
│  │         ┌──────────────────────────┴──────────────────────────────┐         │  │
│  │         │                                                         │         │  │
│  │         ▼                                                         ▼         │  │
│  │  ┌──────────────────────────────┐                    ┌──────────────────────┐ │  │
│  │  │  Private Subnet 1a           │                    │  Private Subnet 1b   │ │  │
│  │  │  CIDR: 10.0.3.0/24           │                    │  CIDR: 10.0.4.0/24   │ │  │
│  │  │  AZ: ap-south-1a             │                    │  AZ: ap-south-1b     │ │  │
│  │  │  Map Public IP: ✗            │                    │  Map Public IP: ✗    │ │  │
│  │  │                              │                    │                      │ │  │
│  │  │  ┌──────────────────────────┐│                    │┌──────────────────────┐│ │  │
│  │  │  │  RDS Instance (Primary)  ││                    ││  RDS Instance        ││ │  │
│  │  │  │  - Engine: MySQL/PG      ││                    ││  (Standby/Replica)   ││ │  │
│  │  │  │  - Class: t3.micro       ││                    ││  - Multi-AZ Failover ││ │  │
│  │  │  │  - Storage: 20 GB        ││                    ││  - Auto Failover     ││ │  │
│  │  │  │  - Port: 3306/5432       ││                    ││  - Sync Replication  ││ │  │
│  │  │  │  - SG: rds-sg            ││                    ││  - SG: rds-sg        ││ │  │
│  │  │  │  - Backup: 7 days        ││                    ││  - Backup: 7 days    ││ │  │
│  │  │  │  - Logs: CloudWatch      ││                    ││  - Logs: CloudWatch  ││ │  │
│  │  │  └──────────────────────────┘│                    │└──────────────────────┘│ │  │
│  │  │         │                     │                    │         │             │ │  │
│  │  │         │ (Credentials)       │                    │         │             │ │  │
│  │  │         ▼                     │                    │         ▼             │ │  │
│  │  │  ┌──────────────────────────┐│                    │┌──────────────────────┐│ │  │
│  │  │  │  DB Subnet Group         ││                    ││  DB Subnet Group     ││ │  │
│  │  │  │  - Subnets: 1a, 1b       ││                    ││  - Subnets: 1a, 1b   ││ │  │
│  │  │  │  - Multi-AZ: ✓           ││                    ││  - Multi-AZ: ✓       ││ │  │
│  │  │  └──────────────────────────┘│                    │└──────────────────────┘│ │  │
│  │  │                              │                    │                      │ │  │
│  │  └──────────────────────────────┘                    └──────────────────────┘ │  │
│  │                                                                              │  │
│  └──────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌──────────────────────────────────────────────────────────────────────────────┐  │
│  │                    AWS Secrets Manager                                       │  │
│  │                                                                              │  │
│  │  Secret Name: rds/dev/appdb/credentials                                     │  │
│  │  ┌────────────────────────────────────────────────────────────────────────┐ │  │
│  │  │  {                                                                     │ │  │
│  │  │    "username": "admin",                                               │ │  │
│  │  │    "password": "[RANDOMLY GENERATED - 16 CHARS WITH SPECIAL CHARS]"  │ │  │
│  │  │  }                                                                     │ │  │
│  │  │                                                                        │ │  │
│  │  │  ⚠️  See RETRIEVE_CREDENTIALS.md for how to access the password      │ │  │
│  │  │                                                                        │ │  │
│  │  │  Encryption: AWS KMS (default)                                        │ │  │
│  │  │  Recovery Window: 7 days                                              │ │  │
│  │  │  Rotation: Disabled (manual only)                                     │ │  │
│  │  └────────────────────────────────────────────────────────────────────────┘ │  │
│  │                                                                              │  │
│  └──────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌──────────────────────────────────────────────────────────────────────────────┐  │
│  │                    CloudWatch Monitoring                                     │  │
│  │                                                                              │  │
│  │  RDS Logs:                                                                  │  │
│  │  - MySQL: error, general, slowquery                                         │  │
│  │  - PostgreSQL: postgresql                                                   │  │
│  │                                                                              │  │
│  │  Metrics:                                                                   │  │
│  │  - CPU Utilization                                                          │  │
│  │  - Database Connections                                                     │  │
│  │  - Storage Space                                                            │  │
│  │  - Read/Write Latency                                                       │  │
│  │                                                                              │  │
│  └──────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            Application Layer                                    │
│                                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐             │
│  │  Web Server 1a   │  │  Web Server 1b   │  │  Web Server 1c   │             │
│  │  (Public Subnet) │  │  (Public Subnet) │  │  (Public Subnet) │             │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘             │
│           │                     │                     │                        │
└───────────┼─────────────────────┼─────────────────────┼────────────────────────┘
            │                     │                     │
            │  (SQL Queries)      │                     │
            │                     │                     │
            └─────────────────────┼─────────────────────┘
                                  │
                                  ▼
            ┌─────────────────────────────────────────┐
            │  Security Group: rds-sg                 │
            │  - Ingress: 3306/5432 from VPC CIDR     │
            │  - Egress: All traffic allowed          │
            └─────────────────────────────────────────┘
                                  │
                                  ▼
            ┌─────────────────────────────────────────┐
            │  RDS Database Instance                  │
            │  - Multi-AZ Deployment                  │
            │  - Automatic Failover                   │
            │  - Synchronous Replication              │
            └─────────────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
        ┌──────────────────────┐    ┌──────────────────────┐
        │  Primary Instance    │    │  Standby Instance    │
        │  (ap-south-1a)       │    │  (ap-south-1b)       │
        │  - Accepts Writes    │    │  - Read-Only         │
        │  - Replicates Data   │    │  - Failover Ready    │
        └──────────────────────┘    └──────────────────────┘
                    │                           │
                    └─────────────┬─────────────┘
                                  │
                                  ▼
            ┌─────────────────────────────────────────┐
            │  AWS Secrets Manager                    │
            │  - Stores Credentials                   │
            │  - Encrypted at Rest                    │
            │  - Audit Trail                          │
            └─────────────────────────────────────────┘
                                  │
                                  ▼
            ┌─────────────────────────────────────────┐
            │  Application Retrieves Credentials      │
            │  - On Startup                           │
            │  - On Credential Rotation               │
            │  - Via IAM Role                         │
            └─────────────────────────────────────────┘
```

## Network Connectivity Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Internet                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  │ (0.0.0.0/0)
                                  ▼
                    ┌─────────────────────────┐
                    │  Internet Gateway (IGW) │
                    └─────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
        ┌──────────────────────┐    ┌──────────────────────┐
        │  Public Subnet 1a    │    │  Public Subnet 1b    │
        │  10.0.1.0/24         │    │  10.0.2.0/24         │
        │  ap-south-1a         │    │  ap-south-1b         │
        │                      │    │                      │
        │  Route Table:        │    │  Route Table:        │
        │  0.0.0.0/0 → IGW     │    │  0.0.0.0/0 → IGW     │
        └──────────────────────┘    └──────────────────────┘
                    │                           │
                    │ (Private Subnets)        │
                    ▼                           ▼
        ┌──────────────────────┐    ┌──────────────────────┐
        │  Private Subnet 1a   │    │  Private Subnet 1b   │
        │  10.0.3.0/24         │    │  10.0.4.0/24         │
        │  ap-south-1a         │    │  ap-south-1b         │
        │                      │    │                      │
        │  Route Table:        │    │  Route Table:        │
        │  0.0.0.0/0 → NAT GW  │    │  0.0.0.0/0 → NAT GW  │
        │                      │    │                      │
        │  ┌────────────────┐  │    │  ┌────────────────┐  │
        │  │  RDS Instance  │  │    │  │  RDS Instance  │  │
        │  │  (Primary)     │  │    │  │  (Standby)     │  │
        │  └────────────────┘  │    │  └────────────────┘  │
        └──────────────────────┘    └──────────────────────┘
                    │                           │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
        ┌──────────────────────┐    ┌──────────────────────┐
        │  Secrets Manager     │    │  CloudWatch Logs     │
        │  - Credentials       │    │  - RDS Logs          │
        │  - Encrypted         │    │  - Metrics           │
        └──────────────────────┘    └──────────────────────┘
```

## Deployment Sequence Diagram

```
First Deployment:
─────────────────

1. Terraform Init
   └─> Download AWS Provider

2. Create VPC
   └─> VPC (10.0.0.0/16)

3. Create Subnets
   ├─> Public Subnet 1a (10.0.1.0/24)
   ├─> Public Subnet 1b (10.0.2.0/24)
   ├─> Private Subnet 1a (10.0.3.0/24)
   └─> Private Subnet 1b (10.0.4.0/24)

4. Create Internet Gateway
   └─> Attach to VPC

5. Create Route Tables
   ├─> Public Route Table (0.0.0.0/0 → IGW)
   └─> Private Route Table (0.0.0.0/0 → NAT)

6. Create Secrets Manager Secret
   ├─> Generate Random Password
   ├─> Create Secret Container
   └─> Store Credentials (JSON)

7. Create RDS Instance
   ├─> Create DB Subnet Group
   ├─> Create Security Group
   ├─> Create RDS Instance (Primary)
   ├─> Create RDS Standby (Multi-AZ)
   └─> Enable CloudWatch Logs

8. Terraform Apply Complete
   └─> All resources created successfully


Subsequent Deployments:
──────────────────────

1. Terraform Init
   └─> Refresh state

2. Retrieve Existing Credentials
   ├─> Query Secrets Manager
   ├─> Get existing secret
   └─> Use existing password (no regeneration)

3. Update RDS Configuration (if needed)
   ├─> Modify instance parameters
   ├─> Update security groups
   └─> Apply changes

4. Terraform Apply Complete
   └─> Infrastructure updated (credentials unchanged)
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Security Layers                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Layer 1: Network Security                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  - VPC Isolation (10.0.0.0/16)                                         │ │
│  │  - Public/Private Subnet Separation                                    │ │
│  │  - Security Groups (Firewall Rules)                                    │ │
│  │  - Network ACLs (Stateless Firewall)                                   │ │
│  │  - RDS in Private Subnets (No Direct Internet Access)                  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  Layer 2: Access Control                                                    │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  - IAM Roles for EC2 Instances                                         │ │
│  │  - IAM Policies for Secrets Manager Access                             │ │
│  │  - Database User Authentication                                        │ │
│  │  - Principle of Least Privilege                                        │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  Layer 3: Data Protection                                                   │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  - RDS Encryption at Rest (KMS)                                        │ │
│  │  - Secrets Manager Encryption (KMS)                                    │ │
│  │  - SSL/TLS for Database Connections                                    │ │
│  │  - Automated Backups (Encrypted)                                       │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  Layer 4: Monitoring & Audit                                                │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  - CloudWatch Logs (RDS Logs)                                          │ │
│  │  - CloudTrail (API Audit)                                              │ │
│  │  - Secrets Manager Audit Trail                                         │ │
│  │  - RDS Performance Insights                                            │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  Layer 5: Disaster Recovery                                                 │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  - Multi-AZ Deployment (Automatic Failover)                            │ │
│  │  - Automated Backups (7-day retention)                                 │ │
│  │  - Point-in-Time Recovery                                              │ │
│  │  - Cross-Region Backup (optional)                                      │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Cost Breakdown

```
Monthly Cost Estimation (ap-south-1):
────────────────────────────────────

┌─────────────────────────────────────────────────────────────┐
│  Component                          Cost        Quantity    │
├─────────────────────────────────────────────────────────────┤
│  VPC                                Free        1           │
│  Subnets                            Free        4           │
│  Internet Gateway                   Free        1           │
│  Route Tables                       Free        2           │
│                                                             │
│  RDS t3.micro (Multi-AZ)            ~$30        1           │
│  RDS Storage (20 GB)                ~$2         20 GB       │
│  RDS Backup Storage                 ~$2         20 GB       │
│  RDS Data Transfer (out)            ~$0         (within VPC)│
│                                                             │
│  Secrets Manager                    ~$0.40      1           │
│  Secrets Manager API Calls          ~$0.05      (per 10k)   │
│                                                             │
│  CloudWatch Logs                    ~$0.50      (RDS logs)  │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  TOTAL MONTHLY COST                 ~$35-40                 │
└─────────────────────────────────────────────────────────────┘

Cost Optimization Tips:
- Use t3.micro for development/testing
- Disable automated backups for non-production
- Use single-AZ for development (save ~50%)
- Use Reserved Instances for production (save ~40%)
```

## Terraform Module Dependencies

```
┌─────────────────────────────────────────────────────────────┐
│                    Root Configuration                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  main.tf                                                    │
│  ├─> module.vpc                                             │
│  ├─> module.secrets_manager                                 │
│  └─> module.rds                                             │
│                                                              │
│  variables.tf                                               │
│  ├─> VPC variables                                          │
│  ├─> RDS variables                                          │
│  └─> Secrets Manager variables                              │
│                                                              │
│  outputs.tf                                                 │
│  ├─> VPC outputs                                            │
│  ├─> RDS outputs                                            │
│  └─> Secrets Manager outputs                                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
    ┌─────────┐          ┌──────────┐      ┌──────────────┐
    │ VPC     │          │ Secrets  │      │ RDS          │
    │ Module  │          │ Manager  │      │ Module       │
    │         │          │ Module   │      │              │
    │ - main  │          │          │      │ - main       │
    │ - vars  │          │ - main   │      │ - vars       │
    │ - out   │          │ - vars   │      │ - out        │
    │         │          │ - out    │      │              │
    └─────────┘          └──────────┘      └──────────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                    Dependency Chain:
                    VPC → Secrets Manager → RDS
```

This comprehensive architecture shows:
- ✅ VPC with public and private subnets
- ✅ Multi-AZ RDS deployment
- ✅ Secrets Manager for credential management
- ✅ Security layers and best practices
- ✅ Data flow and connectivity
- ✅ Cost breakdown
- ✅ Module dependencies
