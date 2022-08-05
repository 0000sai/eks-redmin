output "eks" {
  value = null_resource.eks
}

output "eks-alb-ingress-controller" {
  value = null_resource.eks-alb-ingress-controller
}

output "ebscsi-secretcsi-controllers" {
  value = null_resource.ebscsi-secretcsi-controllers
}
