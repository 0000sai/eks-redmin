#OUTPUT
output "aws-alb-id" {
  value = aws_lb.alb.id
}

output "aws-alb-arn" {
  value = aws_lb.alb.arn
}

output "aws-alb-arn-suffix" {
  value = aws_lb.alb.arn_suffix
}