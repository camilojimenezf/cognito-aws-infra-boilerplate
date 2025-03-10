# Terraform Structure

```
infrastructure/
│── main.tf               # Terraform root configuration
│── variables.tf          # Input variables (e.g., AWS region, environment names)
│── outputs.tf            # Outputs for debugging & connections
│── providers.tf          # AWS provider configuration
│── networking/
│   ├── vpc.tf            # Create VPC, subnets, and security groups
│   ├── alb.tf            # Create ALB for backend
│── storage/
│   ├── s3.tf             # S3 for frontend assets
│   ├── cloudfront.tf     # CloudFront distribution
│── compute/
│   ├── ecs.tf            # ECS cluster & Fargate task for backend
│   ├── ecr.tf            # ECR repository for backend container
│── database/
│   ├── rds.tf            # RDS PostgreSQL database
│── terraform.tfvars      # Actual values for variables
│── backend.tf            # Remote state storage (optional)

```

## Terraform Workflow

1. Initialize the Terraform project

```bash
terraform init
```

2. Plan the changes

```bash
terraform plan -var-file="terraform.tfvars"
```

3. Apply the changes

```bash
terraform apply -var-file="terraform.tfvars"
```

4. Destroy the infrastructure

```bash
terraform destroy -var-file="terraform.tfvars"
```

# Deploying the infrastructure

1. Load the environment variables for the environment you want to deploy to, create a new file called `.env.<environment>` and use the `.env.template` as a template.

```bash
cp .env.template .env.staging
```

_You can still use terraform.tfvars for overrides (e.g., local testing), but .env files take precedence via TF*VAR* (added in terraform.sh)_

2. Make sh executable

```bash
chmod +x terraform.sh
```

3. Plan the changes

```bash
./terraform.sh plan staging
```

4. Run the terraform script with the environment you want to deploy to.

```bash
./terraform.sh apply staging
```

5. Destroy the infrastructure

```bash
./terraform.sh destroy staging
```

# Terraform Variables

- `project_name`: The name of the project. Used for naming resources.
- `aws_region`: The AWS region to deploy the infrastructure to.
- `environment`: The environment to deploy the infrastructure to.
- `profile`: The AWS profile to use.
- `domain_name`: The domain name of the project. without the https or www. prefix (e.g. andes.com). You can use the same domain name for multiple environments because to create subdomains we use the `environment` variable, for example `staging.andes.com`.
