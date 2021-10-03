resource "aws_launch_configuration" "this" {


  name                 = var.launch-configuration-name
  ebs_optimized        = var.ebs_optimized
  image_id             = var.image_id
  instance_type        = var.instance_type

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypted
  }
  iam_instance_profile = var.iam_instance_profile_name
  key_name             = var.key_name
  user_data            = var.user_data

  security_groups = var.security_groups


  enable_monitoring = var.enable_monitoring

  lifecycle {
    create_before_destroy       = true
  }

}

