output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "app_url" {
  value = local.https_enabled ? "https://${aws_lb.this.dns_name}" : "http://${aws_lb.this.dns_name}"
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}
