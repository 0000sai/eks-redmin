#!/bin/bash


TF_VAR_EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME}
TF_VAR_EKS_VERSION=${EKS_VERSION}
TF_VAR_REGION=${REGION}
TF_VAR_NODE_TYPE=${NODE_TYPE}
TF_VAR_TOTAL_NODES=${TOTAL_NODES}
TF_VAR_MIN_NODES=${MIN_NODES}
TF_VAR_MAX_NODES=${MAX_NODES}
TF_VAR_NODE_VOLUME_SIZE_IN_GB=${NODE_VOLUME_SIZE_IN_GB}
TF_VAR_SSH_KEY_NAME=${SSH_KEY_NAME}


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
  --name $TF_VAR_EKS_CLUSTER_NAME \
  --version $TF_VAR_EKS_VERSION \
  --vpc-private-subnets=$PRIVATE_SUBNET_1,$PRIVATE_SUBNET_2,$PRIVATE_SUBNET_3 \
  --vpc-public-subnets=$PUBLIC_SUBNET_1,$PUBLIC_SUBNET_2,$PUBLIC_SUBNET_3 \
  --region "$TF_VAR_REGION" \
  --nodegroup-name worker \
  --node-type $TF_VAR_NODE_TYPE \
  --nodes $TF_VAR_TOTAL_NODES \
  --nodes-min $TF_VAR_MIN_NODES \
  --nodes-max $TF_VAR_MAX_NODES \
  --ssh-access \
  --node-volume-size $TF_VAR_NODE_VOLUME_SIZE_IN_GB \
  --ssh-public-key $TF_VAR_SSH_KEY_NAME \
  --appmesh-access \
  --full-ecr-access \
  --alb-ingress-access \
  --node-private-networking \
  --managed \
  --asg-access \
  --verbose 3

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
