#!/bin/bash
#Purpose: Setup EBS CSI Driver

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

curl -o Amazon_EBS_CSI_Driver.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.9.0/docs/example-iam-policy.json
aws iam create-policy --policy-name Amazon_EBS_CSI_Driver --policy-document file://Amazon_EBS_CSI_Driver.json
ROLE_NAME=$(kubectl -n kube-system describe configmap aws-auth | grep "rolearn" | awk -F ':' '{print $7}' | cut -f2 -d "/")

###########################
# Attach a Policy to a Role
###########################
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/Amazon_EBS_CSI_Driver --role-name ${ROLE_NAME}
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm upgrade -install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-ebs-csi-driver \
    --set controller.serviceAccount.create=true \
    --set controller.serviceAccount.name=ebs-csi-controller-sa
kubectl get all -A

# End
