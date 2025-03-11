# Terraform Structure

```
infrastructure/
│── main.tf               # Terraform root configuration
│── variables.tf          # Input variables (e.g., AWS region, environment names)
│── outputs.tf            # Outputs for debugging & connections
│── providers.tf          # AWS provider configuration
│── networking/
│   ├── vpc.tf              # Create VPC, subnets, and security groups
│   ├── alb.tf              # Create ALB for backend
│   ├── alb_target_group.tf # Create target group for ALB
│   ├── security_groups.tf  # Security group for ALB
│── storage/
│   ├── s3.tf             # S3 for cloudfront distribution
│── compute/
│   ├── ecs.tf            # ECS cluster & Fargate task for backend
│   ├── ecr.tf            # ECR repository for backend container
│── database/
│   ├── rds.tf            # RDS PostgreSQL database
│   ├── security.tf       # Security group for RDS
│   ├── subnet.tf         # Subnet group for RDS
│── integrations/
│   ├── cloudfront.tf      # CloudFront distribution
│   ├── route53_records.tf # Route53 records for the domain
│── dns/
│   ├── route53.tf        # Route53 for DNS
│   ├── certificates.tf   # Certificates for HTTPS
│   ├── alb_https.tf      # ALB for HTTPS
│── terraform.tfvars      # Actual values for variables
│── backend.tf            # Remote state storage (optional)
```

## Terraform Workflow

2. Initialize the Terraform project

```bash
terraform init
```

3. Plan the changes

```bash
terraform plan -var-file="terraform.tfvars"
```

4. Apply the changes

```bash
terraform apply -var-file="terraform.tfvars"
```

5. Destroy the infrastructure

```bash
terraform destroy -var-file="terraform.tfvars"
```

# Deploying the infrastructure

## Required inputs before deploying

You need to have the following inputs before deploying:

- Cognito User Pool ID
- Cognito App Client ID
- Cognito Configuration for Google OAuth. You need to create a Google OAuth client ID and secret and configure the callback URLs and logout URLs with Cognito.
- AWS Access Key ID and Secret Key (IAM user with programmatic access)
- Domain name for the project (e.g. andes.com). You need to have a registered domain on Route53 in hosted zone (e.g. andes.com), terraform will use the existing hosted zone and not create a new one to avoid conflicts with existing DNS records.

## Steps to deploy

1. Create Cognito User Pool on AWS Console

- Create User Pool
- Create App Client
- Create Identity Provider (Google)
- Configure Google OAuth Client ID and Secret
- Configure Callback URLs
- Configure Logout URLs
- Configure Allowed OAuth Flows to Hybrid
- Configure Allowed OAuth Scopes (email, openid)
- Enable sign in with Google
- We will use pool id and app client id in the terraform code on env variables

2. Load the environment variables for the environment you want to deploy to, create a new file called `.env.<environment>` and use the `.env.template` as a template.

```bash
cp .env.template .env.staging
```

_You can still use terraform.tfvars for overrides (e.g., local testing), but .env files take precedence via TF*VAR* (added in terraform.sh)_

3. Make sh executable

```bash
chmod +x terraform.sh
```

4. Plan the changes

```bash
./terraform.sh plan staging
```

5. Run the terraform script with the environment you want to deploy to.

```bash
./terraform.sh apply staging
```

6. Destroy the infrastructure

```bash
./terraform.sh destroy staging
```

# Terraform Variables

- `project_name`: The name of the project. Used for naming resources.
- `aws_region`: The AWS region to deploy the infrastructure to.
- `environment`: The environment to deploy the infrastructure to.
- `aws_access_key`: The AWS access key to use.
- `aws_secret_key`: The AWS secret key to use.
- `domain_name`: The domain name of the project. without the https or www. prefix (e.g. andes.com). You can use the same domain name for multiple environments because to create subdomains we use the `environment` variable, for example `staging.andes.com`.
- `db_name`: The name of the database to create.
- `db_username`: The username of the database to create.
- `db_password`: The password of the database to create.
- `cognito_user_pool_id`: The ID of the Cognito user pool to use.
- `cognito_app_client_id`: The ID of the Cognito app client to use.

# Infrastructure Overview

Now we will cover the infrastructure overview and the resources created by the terraform code.

## Networking

- VPC
  - Main VPC
  - Internet Gateway
  - NAT Gateway
  - Route Tables
    - Public Route Table
    - Private Route Table
  - Subnets
    - Public Subnets
    - Private Subnets
- Security Groups
  - ALB Security Group
  - ECS Security Group
- ALB
  - Application Load Balancer
  - Target Group
    - Backend Target Group (for ECS tasks)

## Compute

- ECS Cluster
- ECS Task Definition
- ECS Service
- ECR Repository

## Storage

- S3 Bucket
  - Used for CloudFront Distribution

## DNS

- Route53 Zone
- Certificates
- ALB for HTTPS
  - Update ALB to use HTTPS and the certificate
  - Redirect rule HTTP to HTTPS

## Integrations

- CloudFront Distribution
- Route53 Records

## Database

- RDS Instance
- Security Group
- Subnet Group
