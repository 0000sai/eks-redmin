variable "launch-configuration-name" {
  description = "Launch Configuration Name"
  type        = string
  default     = ""
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = null
}

variable "iam_instance_profile_name" {
  description = "The name attribute of the IAM instance profile to associate with launched instances"
  type        = string
  default     = null
}

variable "image_id" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of the instance to launch"
  type        = string
  default     = ""
}


variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = null
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "A list of security group IDs to associate"
  type        = list(string)
  default     = null
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = null
}

# Root Block Device

variable "volume_size" {
  description = "The size of the EBS in GB"
  default     = "30"
}

variable "volume_type" {

  description = "The size of the EBS in GB"
  type        = string
  default     = "standard"

}

variable "delete_on_termination" {
  description = "The size of the EBS in GB"
  type        = string
  default     = "true"
}

variable "encrypted" {
  description = "The size of the EBS in GB"
  type        = string
  default     = "false"
}