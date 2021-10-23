#!/bin/bash
#Purpose: Setup EBS CSI Driver

AWS_ACCOUNT="738333021806"

# https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html

# https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html

# https://www.eksworkshop.com/beginner/170_statefulset/ebs_csi_driver/

# 602401143452.dkr.ecr.us-east-1.amazonaws.com/


# AWS Cli Create A Policy

# https://docs.aws.amazon.com/cli/latest/reference/iam/create-policy.html

# https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json

curl -o Amazon_EBS_CSI_Driver_Policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json

aws iam create-policy --policy-name Amazon_EBS_CSI_Driver_Policy --policy-document file://Amazon_EBS_CSI_Driver_Policy.json


ROLE_ARN=$(kubectl -n kube-system describe configmap aws-auth | grep "rolearn" | awk '{print $2}')

ROLE_NAME=$(kubectl -n kube-system describe configmap aws-auth | grep "rolearn" | awk -F ':' '{print $7}' | cut -f2 -d "/")


# Attach a Policy to a Role

# https://docs.aws.amazon.com/cli/latest/reference/iam/attach-role-policy.html

aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT}:policy/Amazon_EBS_CSI_Driver_Policy --role-name ${ROLE_NAME}




helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver

helm repo update

helm upgrade -install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-ebs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=ebs-csi-controller-sa

kubectl get all -A

# End
