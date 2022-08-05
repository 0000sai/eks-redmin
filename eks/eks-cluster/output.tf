output "vpc-id" {
  value = module.vpc.vpc-id
}

output "public-subnet-ids" {
  value = module.vpc.public-subnet-ids
}

output "private-subnets-ids" {
  value = module.vpc.private-subnet-ids
}


output "eks" {
  value = null_resource.eks
}

output "eks-alb-ingress-controller" {
  value = null_resource.eks-alb-ingress-controller
}

output "ebscsi-secretcsi-controllers" {
  value = null_resource.ebscsi-secretcsi-controllers
}
