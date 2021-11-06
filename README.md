# Redmine AWS EKS Setup

# Prerequisites

1. ACM Setup with your domain

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


5. Terraform Destroy
