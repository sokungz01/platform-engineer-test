variable "project_name" {
  description = "Short name used as a prefix for all resources."
  type        = string
  default     = "metabase"
}

variable "environment" {
  description = "Deployment environment. Must be one of dev, staging, prod."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region. Singapore is the nearest region to Bangkok."
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be a /16 so the network module can carve /20 subnets."
  type        = string
  default     = "10.20.0.0/16"
}

variable "metabase_image_tag" {
  description = "Pinned metabase/metabase Docker Hub tag. Never use latest."
  type        = string
}

variable "metabase_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 1024
}

variable "metabase_memory" {
  description = "Fargate task memory in MiB. Metabase needs at least 2048 for production use."
  type        = number
  default     = 2048
}

variable "metabase_desired_count" {
  description = "Number of Metabase tasks."
  type        = number
  default     = 1
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS on the load balancer. Leave null to serve HTTP only."
  type        = string
  default     = null
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the load balancer. Defaults to none, so each environment must list its own allowed networks."
  type        = list(string)
  default     = []
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Metabase application database name."
  type        = string
  default     = "metabase"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "metabase"
}

variable "db_backup_retention_days" {
  description = "Automated backup retention in days."
  type        = number
  default     = 7
}

variable "db_deletion_protection" {
  description = "Protect the database from deletion. Enable for prod."
  type        = bool
  default     = false
}

variable "db_multi_az" {
  description = "Run the database across two AZs. Enable for prod."
  type        = bool
  default     = false
}
