variable "ami" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Type of the instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name for the instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to associate with the instance"
  type        = string
}

variable "name" {
  description = "Name tag for the instance"
  type        = string
}
