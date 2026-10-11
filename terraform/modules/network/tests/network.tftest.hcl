mock_provider "aws" {
  override_data {
    target = data.aws_availability_zones.available
    values = {
      names = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    }
  }
}

variables {
  vpc_cidr    = "10.20.0.0/16"
  name_prefix = "test"
  az_count    = 2
}

run "creates_one_subnet_per_az_per_tier" {
  command = apply

  assert {
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.private) == 2 && length(aws_subnet.database) == 2
    error_message = "expected 2 subnets in each of public, private, and database tiers"
  }
}

run "subnet_cidrs_follow_the_plan" {
  command = apply

  assert {
    condition     = aws_subnet.public[0].cidr_block == "10.20.0.0/20" && aws_subnet.private[0].cidr_block == "10.20.64.0/20" && aws_subnet.database[0].cidr_block == "10.20.128.0/20"
    error_message = "subnet CIDRs do not match the documented plan"
  }
}

run "database_route_table_has_no_internet_route" {
  command = apply

  assert {
    condition     = length([for r in aws_route_table.database.route : r if r.cidr_block == "0.0.0.0/0"]) == 0
    error_message = "database route table must not route 0.0.0.0/0 anywhere"
  }
}

run "public_subnets_do_not_auto_assign_public_ips" {
  command = apply

  assert {
    condition     = alltrue([for s in aws_subnet.public : s.map_public_ip_on_launch == false])
    error_message = "public subnets must not auto-assign public IPs; ECS tasks never run there"
  }
}
