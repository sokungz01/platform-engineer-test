mock_provider "aws" {
  # Nested modules fetch AZ names; mocks return an empty list, which breaks slice().
  override_data {
    target = module.network.data.aws_availability_zones.available
    values = {
      names = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
    }
  }

  mock_resource "aws_lb" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:loadbalancer/app/test-alb/0123456789abcdef"
    }
  }

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/mb-0123456789abcdef/0123456789abcdef"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/test-mb-exec-0123456789abcdef"
    }
  }

  mock_resource "aws_ecs_task_definition" {
    defaults = {
      arn = "arn:aws:ecs:ap-southeast-1:123456789012:task-definition/test-metabase:1"
    }
  }

  mock_resource "aws_secretsmanager_secret" {
    defaults = {
      arn = "arn:aws:secretsmanager:ap-southeast-1:123456789012:secret:test-metabase-encryption-AbCdEf"
    }
  }
}

mock_provider "random" {}

run "rejects_unknown_environment_name" {
  command = plan

  variables {
    environment        = "production"
    metabase_image_tag = "v0.0.0-test"
  }

  expect_failures = [var.environment]
}

run "prod_refuses_to_serve_plain_http" {
  command = plan

  variables {
    environment        = "prod"
    metabase_image_tag = "v0.0.0-test"
    certificate_arn    = null
  }

  expect_failures = [terraform_data.https_required_in_prod]
}

run "default_exposes_no_public_ingress" {
  command = apply

  variables {
    environment        = "dev"
    metabase_image_tag = "v0.0.0-test"
  }

  assert {
    condition     = output.public_ingress_rule_count == 0
    error_message = "with no allowed_ingress_cidrs set, the load balancer must accept no traffic"
  }
}

run "accepts_known_environment_name" {
  command = apply

  variables {
    environment        = "dev"
    metabase_image_tag = "v0.0.0-test"
  }

  assert {
    condition     = output.app_url != null
    error_message = "a valid environment must produce an app URL"
  }
}
