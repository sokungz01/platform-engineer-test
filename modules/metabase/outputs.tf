output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "app_url" {
  value = local.https_enabled ? "https://${aws_lb.this.dns_name}" : "http://${aws_lb.this.dns_name}"
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "public_ingress_rule_count" {
  description = "Number of public ingress rules on the load balancer. Zero means no traffic is allowed."
  value       = length(aws_vpc_security_group_ingress_rule.alb)
}
