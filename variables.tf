variable "project" {
  description = "Short project slug used as the first part of every name."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project))
    error_message = "The project must be 2-21 characters: lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "The environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Team that owns the stack. Required in prod."
  type        = string
  default     = ""

  # Cross-variable validation (Terraform 1.9+): the rule reads var.environment.
  validation {
    condition     = var.environment != "prod" || length(trimspace(var.owner)) > 0
    error_message = "The owner must be set when environment is prod."
  }
}

variable "vpc_cidr" {
  description = "IPv4 range for the whole network, e.g. 10.20.0.0/16."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && can(regex("^[0-9.]+/(1[6-9]|2[0-4])$", var.vpc_cidr))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block with a prefix between /16 and /24."
  }
}

variable "availability_zones" {
  description = "Zones to spread each subnet tier across."
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  validation {
    condition     = length(var.availability_zones) >= 1 && length(var.availability_zones) <= 6
    error_message = "Provide between 1 and 6 availability zones."
  }

  validation {
    condition     = length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "The availability_zones list must not contain duplicates."
  }
}

variable "tiers" {
  description = "Subnet tiers, in the order their address blocks are allocated."
  type        = list(string)
  default     = ["public", "private", "data"]

  validation {
    condition     = length(var.tiers) > 0 && alltrue([for t in var.tiers : can(regex("^[a-z]+$", t))])
    error_message = "The tiers list must be non-empty and hold lowercase words."
  }
}

variable "subnet_newbits" {
  description = "Bits added to the VPC prefix for each subnet (8 turns a /16 into /24s)."
  type        = number
  default     = 8

  validation {
    condition     = var.subnet_newbits >= 1 && var.subnet_newbits <= 8
    error_message = "The subnet_newbits value must be between 1 and 8."
  }

  # Another cross-variable rule: enough blocks for every tier in every zone.
  validation {
    condition     = length(var.tiers) * length(var.availability_zones) <= pow(2, var.subnet_newbits)
    error_message = "Not enough address blocks: tiers x zones exceeds 2^subnet_newbits."
  }
}

variable "extra_tags" {
  description = "Tags merged over the standard tag set. Keys here win."
  type        = map(string)
  default     = {}
}
