#!/bin/bash

# https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html

# https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html

# 602401143452.dkr.ecr.us-east-1.amazonaws.com/


helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver

helm repo update

helm upgrade -install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-ebs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=ebs-csi-controller-sa
    
    
    
# End    
