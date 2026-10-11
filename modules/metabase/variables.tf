variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "database_security_group_id" {
  description = "Security group attached to the RDS instance. This module adds the app ingress rule to it."
  type        = string
}

variable "db_address" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password_secret_arn" {
  description = "Secrets Manager ARN whose value is the database password as a plain string."
  type        = string
}

variable "image_tag" {
  type = string
}

variable "cpu" {
  type    = number
  default = 1024
}

variable "memory" {
  type    = number
  default = 2048
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "certificate_arn" {
  description = "ACM certificate ARN. When set, HTTPS is served and HTTP redirects to it."
  type        = string
  default     = null
}

variable "allowed_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "health_check_path" {
  type    = string
  default = "/api/health"
}
