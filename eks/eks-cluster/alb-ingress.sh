#!/bin/bash
# Purpose: alb ingress setup via helm3

EKS_CLUSTER_NAME="${EKS_CLUSTER_NAME}"

helm version --short

helm repo add eks https://aws.github.io/eks-charts

# To install the TargetGroupBinding custom resource definitions (CRDs), run the following command:


kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"


# To install the Helm chart, run the following command:

helm repo update

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName="${EKS_CLUSTER_NAME}"

# END
