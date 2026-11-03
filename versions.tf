terraform {
  # 1.9 is the floor: cross-variable validation (var.owner checks
  # var.environment) does not exist in older releases.
  required_version = ">= 1.9.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
