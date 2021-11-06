#ALB VARIABLES

variable "alb-name" {
  default = ""
}

variable "internal" {
  default = "false"
}

variable "enable_cross_zone_load_balancing" {
  default = "false"
}

variable "enable_deletion_protection" {
  default = "false"
}

variable "enable_http2" {
  default = "false"
}



variable "alb-sg" {
  default = ""
}

variable "alb-subnets" {
  type = list(string)
}

variable "alb-tag" {
  default = ""
}


