output "address" {
  value = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "username" {
  value = aws_db_instance.this.username
}

output "security_group_id" {
  value = aws_security_group.database.id
}

output "password_secret_arn" {
  description = "Secrets Manager ARN whose value is the database password as a plain string."
  value       = aws_secretsmanager_secret.db_password.arn
}
