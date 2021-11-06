resource "aws_lb" "alb" {
  name               = var.alb-name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb-sg]
  subnets            = var.alb-subnets


  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2



  tags = {
    Name = var.alb-tag
  }
}
