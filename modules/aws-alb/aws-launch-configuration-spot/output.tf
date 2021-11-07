output "launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = element(concat(aws_launch_configuration.this.*.id, [""]), 0)
}

output "launch_configuration_arn" {
  description = "The ARN of the launch configuration"
  value       = element(concat(aws_launch_configuration.this.*.arn, [""]), 0)
}

output "launch_configuration_name" {
  description = "The name of the launch configuration"
  value       = element(concat(aws_launch_configuration.this.*.name, [""]), 0)
}
