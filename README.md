# Redmine AWS EKS Setup

# Deployments 

1. Terraform Vpc
2. Terraform Eks(eksctl)
3. Terraform Rds
4. Terraform Kms
5. Terraform Eks-Drivers-(EBS-CSI + SecretStore-CSI)
6. Terraform ALB-Ingress-Setup
# AWS SecretManager
7. Eks-Application/SecretsDecryption-OIDC

# Bitnami Sealed Secrets
8. Bitnami Sealed Secrets 

# Prerequisites

1. ACM Setup with your domain (Optional)

2. packages Installed in provided packages.sh

3. Docker (Optional)

4. VsCode (Optional)

# Steps

1. cd eks/environment/dev

2. aws configure 

3. terraform apply

4. Resources Provisioned VPC, RDS, KMS, AWS Secrets,EKS CLUSTER, EKS Manged Nodes

# MYSQL Client
# Connect to MYSQL Database 
# Make Sure to Allow WorkerNodeSG in RDS SG
kubectl run -it --rm --image=mysql:5.7 --restart=Never mysql-client -- mysql -h redmine-db.cpyuhbq10eou.us-east-1.rds.amazonaws.com -u dbadmin -p12345678

# Verify Database
mysql> show schemas;

#######################################
# Creds Create these in Secret Manager
#######################################

# Best is to Use Bitnami Sealed Secrets, currently aws does not provide KEY Value

REDMINE_DB_USERNAME=dbadmin         ---> # Create these in Secret Manager
REDMINE_DB_PASSWORD=12345678        ---> # Create these in Secret Manager
REDMINE_SECRET_KEY_BASE=12345678    ---> # Create these in Secret Manager
REDMINE_DB_MYSQL                    ---> # Create these in Secret Manager        # Rds Endpoint

rds-secrets

export REDMINE_DB_USERNAME=$(aws secretsmanager get-secret-value --secret-id rds-secrets --region us-east-1 --query SecretString --output text | jq '."REDMINE_DB_USERNAME"' | cut -f2 -d '"')

export REDMINE_DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id rds-secrets --region us-east-1 --query SecretString --output text | jq '."REDMINE_DB_PASSWORD"' | cut -f2 -d '"')

export REDMINE_SECRET_KEY_BASE=$(aws secretsmanager get-secret-value --secret-id rds-secrets --region us-east-1 --query SecretString --output text | jq '."REDMINE_SECRET_KEY_BASE"' | cut -f2 -d '"')

export REDMINE_DB_MYSQL=$(aws secretsmanager get-secret-value --secret-id rds-secrets --region us-east-1 --query SecretString --output text | jq '."REDMINE_DB_MYSQL"' | cut -f2 -d '"')


5. Terraform Destroy
