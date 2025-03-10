#!/bin/bash

# Usage: ./terraform.sh <command> <environment>
# Example: ./terraform.sh apply staging

COMMAND=$1
ENVIRONMENT=$2

if [ -z "$COMMAND" ] || [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <terraform-command> <environment>"
  echo "Example: $0 apply staging"
  exit 1
fi

ENV_FILE=".env.${ENVIRONMENT}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found"
  exit 1
fi

# Generate terraform.tfvars from .env file
echo "# Generated terraform.tfvars from $ENV_FILE" > terraform.tfvars
grep -v '^#' "$ENV_FILE" | grep -v '^$' | while read -r line; do
  key=$(echo "$line" | cut -d= -f1 | xargs)
  value=$(echo "$line" | cut -d= -f2- | xargs | sed 's/^"//;s/"$//')
  
  echo "Processing: $key = $value"
  
  # Convert key to lowercase
  key_lower=$(echo "$key" | tr '[:upper:]' '[:lower:]')
  
  # Write to terraform.tfvars
  echo "${key_lower} = \"${value}\"" >> terraform.tfvars
done

# Optional: Load sensitive vars from Secrets Manager (e.g., for production)
# if [ "$ENVIRONMENT" = "production" ]; then
#   DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id db-password --query SecretString --output text)
#   echo "db_password = \"$DB_PASSWORD\"" >> terraform.tfvars
# fi

# Run Terraform command with generated tfvars
terraform "$COMMAND" -var-file=terraform.tfvars

# Check exit code
if [ $? -eq 0 ]; then
  echo "Terraform $COMMAND completed successfully for $ENVIRONMENT"
else
  echo "Terraform $COMMAND failed for $ENVIRONMENT"
  exit 1
fi

# Optional: Clean up terraform.tfvars after run (uncomment if desired)
# rm -f terraform.tfvars