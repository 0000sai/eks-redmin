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
  required_version = ">= 0.15, >= 0.12"
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





########################
# EKS Cluster Deployment
########################
resource "null_resource" "eks" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "bash eksctl.sh"
  }
  depends_on = [module.redmine-rds]
}



#############################
# EKS ALB Ingress Deployment
#############################
resource "null_resource" "eks-alb-ingress-controller" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "bash alb-ingress.sh"
  }
  depends_on = [null_resource.eks]
}


################################
# EKS EBS/SecretStore CSI Driver
################################
resource "null_resource" "ebscsi-secretcsi-controllers" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "bash csi-drivers.sh"
  }
  depends_on = [null_resource.eks]
}

