
resource "aws_security_group" "sg" {
  name          = var.security-group-name
  description   = "aws dynamic security groups"
  vpc_id        = var.vpc-id

  dynamic "ingress" {
    for_each = var.sg_ingress
    content {

      description      = var.sg-description
      from_port        = ingress.value.port
      to_port          = ingress.value.port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.cidr_blocks_ipv6
    }
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.security-group-name
  }
}