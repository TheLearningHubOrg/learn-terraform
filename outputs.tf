output "name_prefix" {
  description = "The project-environment prefix shared by every name."
  value       = local.name_prefix
}

output "resource_name" {
  description = "Full name including the random suffix (known after apply)."
  value       = "${local.name_prefix}-${random_pet.suffix.id}"
}

output "tags" {
  description = "Standard tags merged with extra_tags."
  value       = local.common_tags
}

output "subnet_cidrs" {
  description = "Map of tier-zone key to CIDR block."
  value       = { for key, s in module.subnets.subnets : key => s.cidr }
}

output "subnets_by_tier" {
  description = "CIDR blocks grouped by tier, in zone order."
  # The trailing ellipsis switches the for expression to grouping mode.
  value = { for s in module.subnets.subnet_list : s.tier => s.cidr... }
}

output "document_path" {
  description = "Where the rendered network plan is written."
  value       = local_file.network_plan.filename
}
