variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_subnet_ids" {
  description = "Subnets with no internet route. Must span at least two AZs."
  type        = list(string)
}

variable "engine_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "max_allocated_storage" {
  description = "Upper bound for storage autoscaling in GiB."
  type        = number
  default     = 100
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "backup_retention_days" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

variable "multi_az" {
  type = bool
}
