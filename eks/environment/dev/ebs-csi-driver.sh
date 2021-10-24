#!/bin/bash
#Purpose: Setup EBS CSI Driver

AWS_ACCOUNT="049043308513"          # Update This

# https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/

# https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html



# 602401143452.dkr.ecr.us-east-1.amazonaws.com/


# AWS Cli Create A Policy

# https://docs.aws.amazon.com/cli/latest/reference/iam/create-policy.html

# https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json


#cat << EOF > Amazon_EBS_CSI_Driver.json
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": [
#        "ec2:AttachVolume",
#        "ec2:CreateSnapshot",
#        "ec2:CreateTags",
#        "ec2:CreateVolume",
#        "ec2:DeleteSnapshot",
#        "ec2:DeleteTags",
#        "ec2:DeleteVolume",
#        "ec2:DescribeAvailabilityZones",
#        "ec2:DescribeInstances",
#        "ec2:DescribeSnapshots",
#        "ec2:DescribeTags",
#        "ec2:DescribeVolumes",
#        "ec2:DescribeVolumesModifications",
#        "ec2:DetachVolume",
#        "ec2:ModifyVolume"
#      ],
#      "Resource": "*"
#    }
#  ]
#}
#
#EOF

curl -o Amazon_EBS_CSI_Driver.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.9.0/docs/example-iam-policy.json

aws iam create-policy --policy-name Amazon_EBS_CSI_Driver --policy-document file://Amazon_EBS_CSI_Driver.json


ROLE_ARN=$(kubectl -n kube-system describe configmap aws-auth | grep "rolearn" | awk '{print $2}')

ROLE_NAME=$(kubectl -n kube-system describe configmap aws-auth | grep "rolearn" | awk -F ':' '{print $7}' | cut -f2 -d "/")


# Attach a Policy to a Role

# https://docs.aws.amazon.com/cli/latest/reference/iam/attach-role-policy.html

aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT}:policy/Amazon_EBS_CSI_Driver --role-name ${ROLE_NAME}




helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver

helm repo update

helm upgrade -install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-ebs-csi-driver \
    --set controller.serviceAccount.create=true \
    --set controller.serviceAccount.name=ebs-csi-controller-sa

kubectl get all -A

# End
