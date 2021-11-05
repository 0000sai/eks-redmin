#!/bin/bash


EKS_CLUSTER_NAME="cloudgeeks-ca-eks"
EKS_VERSION="1.21"
REGION="us-east-1"
NODE_TYPE="t3a.medium"
TOTAL_NODES="1"
MIN_NODES="1"
MAX_NOES="2"
NODE_VOLUME_SIZE_IN_GB="30"
SSH_KEY_NAME="cloudgeeks-ca-eks"
KMS_KEY_ID=$(aws kms describe-key --key-id alias/readmines | awk -F ':' '{print $6}' | cut -f2 -d "/" | awk '{print $1}')


PRIVATE_SUBNET_1=`terraform output private-subnets-ids | sed -n 2p | cut -d'"' -f2`
PRIVATE_SUBNET_2=`terraform output private-subnets-ids | sed -n 3p | cut -d'"' -f2`
PRIVATE_SUBNET_3=`terraform output private-subnets-ids | sed -n 4p | cut -d'"' -f2`


PUBLIC_SUBNET_1=`terraform output public-subnet-ids | sed -n 2p | cut -d'"' -f2`
PUBLIC_SUBNET_2=`terraform output public-subnet-ids | sed -n 3p | cut -d'"' -f2`
PUBLIC_SUBNET_3=`terraform output public-subnet-ids | sed -n 4p | cut -d'"' -f2`






# Creating a key pair for EC2 Workers Nodes

if [ -d ~/.ssh ]
then
    echo "Directory .ssh exists."
else

    mkdir -p ~/.ssh
fi


aws ec2 create-key-pair --key-name $SSH_KEY_NAME --query 'KeyMaterial' --output text > ~/.ssh/$SSH_KEY_NAME.pem


# Eks Cluster Creation

eksctl create cluster \
  --name $EKS_CLUSTER_NAME \
  --version $EKS_VERSION \
  --vpc-private-subnets=$PRIVATE_SUBNET_1,$PRIVATE_SUBNET_2,$PRIVATE_SUBNET_3 \
  --vpc-public-subnets=$PUBLIC_SUBNET_1,$PUBLIC_SUBNET_2,$PUBLIC_SUBNET_3 \
  --region "$REGION" \
  --nodegroup-name worker \
  --node-type $NODE_TYPE \
  --nodes $TOTAL_NODES \
  --nodes-min $MIN_NODES \
  --nodes-max $MAX_NOES \
  --ssh-access \
  --node-volume-size $NODE_VOLUME_SIZE_IN_GB \
  --ssh-public-key $SSH_KEY_NAME \
  --appmesh-access \
  --full-ecr-access \
  --alb-ingress-access \
  --node-private-networking \
  --managed \
  --asg-access \
  --verbose 3




# EKS Secrets with KMS
# eksctl utils enable-secrets-encryption --cluster=kms-cluster --key-arn=arn:aws:kms:us-west-2:<account>:key/<key> --region=<region>


# aws kms describe-key --key-id alias/readmines
# Note: Key is created through terraform
#if [ "$?" = "0" ]
#then
#eksctl utils enable-secrets-encryption --cluster=${EKS_CLUSTER_NAME} --key-arn=arn:aws:kms:${REGION}:${AWS_ACCOUNT}:key/${KMS_KEY_ID} --region=${REGION}
#fi

  
# aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $REGION




# UPDATE YOUR ./kube
################################################################
### MUST ###
###---> aws eks update-kubeconfig --name cloudgeeks-ca-eks --region us-east-1 <---
##################################################################

# Update Public to Private End Points
# aws eks update-cluster-config --name cloudgeeks-ca-eks --region us-east-1 \
# --resources-vpc-config endpointPublicAccess=false,endpointPrivateAccess=true

#END
