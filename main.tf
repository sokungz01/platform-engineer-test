locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "network" {
  source = "./modules/network"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
  az_count    = 2
}

module "database" {
  source = "./modules/database"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  database_subnet_ids   = module.network.database_subnet_ids
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  db_name               = var.db_name
  username              = var.db_username
  backup_retention_days = var.db_backup_retention_days
  deletion_protection   = var.db_deletion_protection
  multi_az              = var.db_multi_az
}

module "metabase" {
  source = "./modules/metabase"

  name_prefix                = local.name_prefix
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  private_subnet_ids         = module.network.private_subnet_ids
  database_security_group_id = module.database.security_group_id
  db_address                 = module.database.address
  db_port                    = module.database.port
  db_name                    = module.database.db_name
  db_username                = module.database.username
  db_password_secret_arn     = module.database.password_secret_arn
  image_tag                  = var.metabase_image_tag
  cpu                        = var.metabase_cpu
  memory                     = var.metabase_memory
  desired_count              = var.metabase_desired_count
  certificate_arn            = var.certificate_arn
  allowed_ingress_cidrs      = var.allowed_ingress_cidrs
}

# Production must serve HTTPS. Without a certificate the load balancer would serve plain HTTP.
resource "terraform_data" "https_required_in_prod" {
  lifecycle {
    precondition {
      condition     = var.environment != "prod" || var.certificate_arn != null
      error_message = "prod must serve HTTPS: set certificate_arn to an ACM certificate ARN."
    }
  }
}
