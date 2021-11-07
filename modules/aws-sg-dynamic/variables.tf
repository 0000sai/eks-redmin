variable "vpc-id" {}

variable "security-group-name" {}


variable "sg_ingress" {
  type = map(object({

    port             = number
    protocol         = string
    cidr_blocks      = list(string)
    cidr_blocks_ipv6 = list(string)

  }))
}


variable "sg-description" {}