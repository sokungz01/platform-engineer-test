mock_provider "aws" {
  # Mocked providers fill computed attributes with random strings. Several of these
  # ARNs are passed into ARN-typed arguments elsewhere, so they need valid-looking defaults.
  mock_resource "aws_lb" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/test-alb/0123456789abcdef"
    }
  }

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:targetgroup/mb-0123456789abcdef/0123456789abcdef"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/test-mb-exec-0123456789abcdef"
    }
  }

  mock_resource "aws_ecs_task_definition" {
    defaults = {
      arn = "arn:aws:ecs:ap-southeast-2:123456789012:task-definition/test-metabase:1"
    }
  }

  mock_resource "aws_secretsmanager_secret" {
    defaults = {
      arn = "arn:aws:secretsmanager:ap-southeast-2:123456789012:secret:test-metabase-encryption-AbCdEf"
    }
  }
}

mock_provider "random" {}

variables {
  name_prefix                = "test"
  vpc_id                     = "vpc-0123456789abcdef0"
  public_subnet_ids          = ["subnet-pub-a", "subnet-pub-b"]
  private_subnet_ids         = ["subnet-prv-a", "subnet-prv-b"]
  database_security_group_id = "sg-0db0000000000000"
  db_address                 = "test-postgres.example.internal"
  db_port                    = 5432
  db_name                    = "metabase"
  db_username                = "metabase"
  db_password_secret_arn     = "arn:aws:secretsmanager:ap-southeast-2:123456789012:secret:test-db-password-AbCdEf"
  image_tag                  = "v0.0.0-test"
  cpu                        = 1024
  memory                     = 2048
  desired_count              = 1
  certificate_arn            = null
  allowed_ingress_cidrs      = ["0.0.0.0/0"]
  health_check_path          = "/api/health"
}

run "db_password_is_only_injected_as_a_secret" {
  command = apply

  assert {
    condition     = length([for e in jsondecode(aws_ecs_task_definition.this.container_definitions)[0].environment : e if e.name == "MB_DB_PASS"]) == 0
    error_message = "MB_DB_PASS must never be a plain-text environment variable"
  }

  assert {
    condition     = length([for s in jsondecode(aws_ecs_task_definition.this.container_definitions)[0].secrets : s if s.name == "MB_DB_PASS"]) == 1
    error_message = "MB_DB_PASS must be injected from Secrets Manager via the secrets block"
  }
}

run "database_accepts_traffic_only_from_app_security_group" {
  command = apply

  assert {
    condition     = aws_vpc_security_group_ingress_rule.database_from_app.referenced_security_group_id == aws_security_group.app.id && aws_vpc_security_group_ingress_rule.database_from_app.from_port == 5432
    error_message = "database must accept only PostgreSQL traffic from the app security group"
  }
}

run "health_check_uses_metabase_health_endpoint" {
  command = apply

  assert {
    condition     = aws_lb_target_group.this.health_check[0].path == "/api/health"
    error_message = "target group must health-check /api/health"
  }
}

run "service_has_grace_period_for_slow_startup" {
  command = apply

  assert {
    condition     = aws_ecs_service.this.health_check_grace_period_seconds >= 300
    error_message = "Metabase needs a grace period of at least 300s before health checks count"
  }
}

run "http_only_when_no_certificate" {
  command = apply

  assert {
    condition     = length(aws_lb_listener.https) == 0
    error_message = "without a certificate there must be no HTTPS listener"
  }
}

run "https_with_redirect_when_certificate_given" {
  command = apply

  variables {
    certificate_arn = "arn:aws:acm:ap-southeast-2:123456789012:certificate/abcd-1234"
  }

  assert {
    condition     = length(aws_lb_listener.https) == 1 && aws_lb_listener.http.default_action[0].type == "redirect"
    error_message = "with a certificate, HTTPS must exist and HTTP must redirect"
  }
}
