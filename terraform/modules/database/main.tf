resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db"
  subnet_ids = var.database_subnet_ids

  tags = { Name = "${var.name_prefix}-db" }
}

# No ingress rules here. The metabase module adds the single rule that permits the app tier.
resource "aws_security_group" "database" {
  name_prefix = "${var.name_prefix}-db-"
  vpc_id      = var.vpc_id
  description = "PostgreSQL. Ingress is added by the consuming module."

  lifecycle {
    create_before_destroy = true
  }
}

# Terraform owns the password instead of RDS-managed rotation, because RDS rotates
# managed passwords every 7 days and running Metabase tasks would keep the stale one.
# RDS rejects '/', '@', '"' and spaces, so those are excluded.
resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_password" {
  name_prefix             = "${var.name_prefix}-db-password-"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}

resource "aws_db_instance" "this" {
  identifier                 = "${var.name_prefix}-postgres"
  engine                     = "postgres"
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = var.max_allocated_storage
  storage_type               = "gp3"
  storage_encrypted          = true
  db_name                    = var.db_name
  username                   = var.username
  password                   = random_password.db.result
  db_subnet_group_name       = aws_db_subnet_group.this.name
  vpc_security_group_ids     = [aws_security_group.database.id]
  publicly_accessible        = false
  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_days
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = !var.deletion_protection
  final_snapshot_identifier  = "${var.name_prefix}-postgres-final"
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = { Name = "${var.name_prefix}-postgres" }
}
