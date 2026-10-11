variable "name_prefix" {
  description = "Prefix for resource names and tags."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR. Must be a /16."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use."
  type        = number
  default     = 2
}
