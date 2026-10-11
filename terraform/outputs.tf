output "app_url" {
  description = "Public URL of the Metabase web application."
  value       = module.metabase.app_url
}

output "alb_dns_name" {
  value = module.metabase.alb_dns_name
}

output "db_address" {
  description = "Private DNS name of the PostgreSQL instance. Resolvable only inside the VPC."
  value       = module.database.address
}

output "public_ingress_rule_count" {
  value = module.metabase.public_ingress_rule_count
}
