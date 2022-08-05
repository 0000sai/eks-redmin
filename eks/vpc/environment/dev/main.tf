terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
 #    version = "3.37.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"
}


### Backend ###
# S3
###############

# Create S3 Bucket with Versioning enabled

# aws s3api create-bucket --bucket cloudgeeks-terraform --region us-east-1

# aws s3api put-bucket-versioning --bucket cloudgeeks-terraform --versioning-configuration Status=Enabled

#############
# S3 Backend
#############

terraform {
  backend "s3" {
    bucket         = "cloudgeeks-terraform"
    key            = "cloudgeeks-staging.tfstate"
    region         = "us-east-1"
  #  dynamodb_table = "dev-cloudgeeks"

  }
}

###################
# Eks Cluster Name  # Update Eks Cluster Environment Variables ---> Do it Manually  # source EKS.env
###################
#resource "null_resource" "eks-cluster-environment-variables" {
#  provisioner "local-exec" {
#    interpreter = ["/bin/bash", "-c"]    # Interpreter
#    command = "source EKS.env"
#  }
#}

#######
# Vpc
#######

module "vpc" {
  source = "../../modules/vpc"
  vpc-location                        = "Virginia"
  namespace                           = "cloudgeeks.ca"
  name                                = "vpc"
  stage                               = "dev"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  vpc-cidr                            = "10.11.0.0/16"
  vpc-public-subnet-cidr              = ["10.11.16.0/20","10.11.32.0/20","10.11.48.0/20"]
  vpc-private-subnet-cidr             = ["10.11.64.0/20","10.11.80.0/20","10.11.96.0/20"]
  vpc-database_subnets-cidr           = ["10.11.112.0/20", "10.11.128.0/20","10.11.144.0/20"]
  cluster-name                        = var.EKS_CLUSTER_NAME

}

################
# Secret Manager
################
module "rds_secret" {
  source               = "../../modules/aws-secret-manager"
  namespace            = "cloudgeeks.ca"
  stage                = "dev"
  name                 = "redmine-rds-creds"
  secret-string         = {
    username             = "dbadmin"
    password             = var.secret-manager
    engine               = "mysql"
    host                 = module.rds-mysql.rds-end-point
    port                 = "3306"
    dbInstanceIdentifier = module.rds-mysql.rds-identifier
  }
  kms_key_id             = module.kms_rds-mysql_key.key_id
}

module "kms_rds-mysql_key" {
  source                  = "../../modules/aws-kms"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "rds-mysql-key"
  alias                   = "alias/redmine"
  deletion_window_in_days = "10"
}


###########
### RDS ##
############
module "rds-mysql" {
  source                                                           = "../../modules/aws-rds-mysql"
  namespace                                                        = "cloudgeeks.ca"
  stage                                                            = "dev"
  db-name                                                          = "redmine"
  rds-identifier                                                   = "redmine"
  final-snapshot-identifier                                        = "redmine-db-final-snap-shot"
  skip-final-snapshot                                              = "true"
  rds-allocated-storage                                            = "5"
  storage-type                                                     = "gp2"
  rds-engine                                                       = "mysql"
  engine-version                                                   = "5.7.38"
  db-instance-class                                                = "db.t2.micro"
  backup-retension-period                                          = "0"
  backup-window                                                    = "04:00-06:00"
  publicly-accessible                                              = "false"
  rds-username                                                     = "dbadmin"
  rds-password                                                     = var.rds-secret
  multi-az                                                         = "true"
  storage-encrypted                                                = "false"
  deletion-protection                                              = "false"
  vpc-security-group-ids                                           = [module.redmine-rds.aws_security_group_default]
  subnet_ids                                                       = module.vpc.database_subnets
  db-subnet-group-name                                             = "readmine"
}




#######################
### Security Groups ###
#######################
module "redmine-web-sq" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "redmine"
  tcp_ports           = "80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "WebSec"
  vpc_id              = module.vpc.vpc-id
}


module "redmine-rds" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "redmine-Rds"
  tcp_ports               = "3306"
  ref_security_groups_ids = [module.redmine-web-sq.aws_security_group_default]
  security_group_name     = "DBSec"
  vpc_id                  = module.vpc.vpc-id
}
