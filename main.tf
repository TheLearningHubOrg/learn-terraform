locals {
  name_prefix = "${var.project}-${var.environment}"

  # Later maps win in merge(), so callers can override any standard tag.
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "terraform"
    },
    var.extra_tags,
  )

  document_path = "${path.root}/out/${local.name_prefix}-network.json"
}

# A stable random suffix. It changes only when a keeper changes, so the
# name survives every other edit to the configuration.
resource "random_pet" "suffix" {
  length = 2

  keepers = {
    project     = var.project
    environment = var.environment
  }
}

# A child module with no resources: it only computes the address plan.
module "subnets" {
  source = "./modules/subnet-plan"

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tiers              = var.tiers
  newbits            = var.subnet_newbits
}

# terraform_data (Terraform 1.4+) replaces null_resource. It is replaced
# whenever the subnet layout changes, which gives downstream automation a
# single "network revision" value to react to.
resource "terraform_data" "network_revision" {
  input            = sha256(jsonencode(module.subnets.subnets))
  triggers_replace = [module.subnets.subnets]
}

resource "local_file" "network_plan" {
  filename        = local.document_path
  file_permission = "0644"

  content = jsonencode({
    name     = "${local.name_prefix}-${random_pet.suffix.id}"
    revision = terraform_data.network_revision.output
    vpc_cidr = var.vpc_cidr
    subnets  = module.subnets.subnets
    tags     = local.common_tags
  })

  lifecycle {
    postcondition {
      condition     = length(jsondecode(self.content).subnets) == length(var.tiers) * length(var.availability_zones)
      error_message = "The rendered document must list one subnet per tier per zone."
    }
  }
}

# check blocks report a warning but never fail the run: use them for
# "should" rules that are not worth blocking a deploy over.
check "address_space_headroom" {
  assert {
    condition     = module.subnets.used_addresses * 2 <= module.subnets.total_addresses
    error_message = "Subnets use more than half of ${var.vpc_cidr}; leave room to grow."
  }
}
