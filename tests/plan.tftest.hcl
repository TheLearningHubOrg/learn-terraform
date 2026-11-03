# Plan-only tests: no provider ever creates anything, so they run in
# milliseconds and are safe on any machine.

variables {
  project     = "acme"
  environment = "dev"
  owner       = "platform-team"
}

run "name_prefix_and_tags" {
  command = plan

  assert {
    condition     = output.name_prefix == "acme-dev"
    error_message = "The name prefix must be project-environment."
  }

  assert {
    condition     = output.tags["ManagedBy"] == "terraform" && output.tags["Owner"] == "platform-team"
    error_message = "Standard tags are missing or wrong."
  }
}

run "extra_tags_override_standard_tags" {
  command = plan

  variables {
    extra_tags = { ManagedBy = "platform-pipeline", CostCenter = "cc-1" }
  }

  assert {
    condition     = output.tags["ManagedBy"] == "platform-pipeline"
    error_message = "extra_tags must win over the standard tags in merge()."
  }

  assert {
    condition     = length(output.tags) == 5
    error_message = "Expected the four standard tags plus CostCenter."
  }
}

run "subnets_are_carved_in_tier_then_zone_order" {
  command = plan

  assert {
    condition     = length(output.subnet_cidrs) == 9
    error_message = "Three tiers across three zones must give nine subnets."
  }

  assert {
    condition     = output.subnet_cidrs["public-eu-west-1a"] == "10.20.0.0/24"
    error_message = "The first public subnet must take block 0."
  }

  assert {
    condition     = output.subnet_cidrs["private-eu-west-1a"] == "10.20.3.0/24"
    error_message = "The private tier must start after the three public blocks."
  }

  assert {
    condition     = output.subnets_by_tier["data"] == ["10.20.6.0/24", "10.20.7.0/24", "10.20.8.0/24"]
    error_message = "Grouping by tier must keep zone order."
  }
}

run "smaller_vpc_gives_smaller_subnets" {
  command = plan

  variables {
    vpc_cidr           = "192.168.0.0/22"
    availability_zones = ["az1", "az2"]
    tiers              = ["app"]
    subnet_newbits     = 2
  }

  assert {
    condition     = output.subnets_by_tier["app"] == ["192.168.0.0/24", "192.168.1.0/24"]
    error_message = "A /22 split with 2 new bits must give /24 blocks."
  }
}
