# Each run feeds one bad input and expects exactly that variable's
# validation to fail. A run that fails for any other reason fails the test.

variables {
  project = "acme"
}

run "rejects_unknown_environment" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}

run "prod_requires_owner" {
  command = plan

  variables {
    environment = "prod"
    owner       = "   "
  }

  expect_failures = [var.owner]
}

run "rejects_invalid_cidr" {
  command = plan

  variables {
    vpc_cidr = "10.20.0.0/33"
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_too_large_vpc" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/8"
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_duplicate_zones" {
  command = plan

  variables {
    availability_zones = ["eu-west-1a", "eu-west-1a"]
  }

  expect_failures = [var.availability_zones]
}

run "rejects_too_few_address_blocks" {
  command = plan

  variables {
    subnet_newbits = 2
  }

  expect_failures = [var.subnet_newbits]
}

run "rejects_bad_project_slug" {
  command = plan

  variables {
    project = "Acme_Corp"
  }

  expect_failures = [var.project]
}
