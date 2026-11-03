output "subnet_list" {
  description = "Subnets as an ordered list of objects."
  value       = local.subnet_list
}

output "subnets" {
  description = "Subnets keyed by tier-zone, ready for for_each."
  value       = { for s in local.subnet_list : s.key => s }
}

output "total_addresses" {
  description = "Addresses in the parent range."
  value       = pow(2, 32 - local.parent_prefix)
}

output "used_addresses" {
  description = "Addresses allocated to subnets."
  value       = local.subnet_size * length(local.subnet_list)
}
