mock_provider "aws" {}
mock_provider "random" {}

variables {
  name_prefix           = "test"
  vpc_id                = "vpc-0123456789abcdef0"
  database_subnet_ids   = ["subnet-aaaa", "subnet-bbbb"]
  engine_version        = "16"
  instance_class        = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  db_name               = "metabase"
  username              = "metabase"
  backup_retention_days = 7
  deletion_protection   = false
  multi_az              = false
}

run "database_is_never_publicly_accessible" {
  command = apply

  assert {
    condition     = aws_db_instance.this.publicly_accessible == false
    error_message = "PostgreSQL must not be publicly accessible"
  }
}

run "storage_is_encrypted" {
  command = apply

  assert {
    condition     = aws_db_instance.this.storage_encrypted == true
    error_message = "RDS storage must be encrypted at rest"
  }
}

run "secret_holds_the_same_password_the_database_uses" {
  command = apply

  assert {
    condition     = aws_secretsmanager_secret_version.db_password.secret_string == random_password.db.result
    error_message = "the secret Metabase reads must contain exactly the password set on the database"
  }
}

run "dev_settings_allow_teardown" {
  command = apply

  assert {
    condition     = aws_db_instance.this.deletion_protection == false && aws_db_instance.this.skip_final_snapshot == true
    error_message = "dev should be easy to tear down"
  }
}

run "prod_settings_protect_data" {
  command = apply

  variables {
    deletion_protection = true
    multi_az            = true
  }

  assert {
    condition     = aws_db_instance.this.deletion_protection == true && aws_db_instance.this.skip_final_snapshot == false && aws_db_instance.this.multi_az == true
    error_message = "prod must enable deletion protection, take a final snapshot, and run multi-AZ"
  }
}
