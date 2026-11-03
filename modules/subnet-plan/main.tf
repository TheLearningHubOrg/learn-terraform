locals {
  zone_count = length(var.availability_zones)

  # Block number = tier_index * zone_count + zone_index. Adding a zone
  # renumbers every later block, so append new tiers at the end instead.
  subnet_list = flatten([
    for tier_index, tier in var.tiers : [
      for zone_index, zone in var.availability_zones : {
        key  = "${tier}-${zone}"
        tier = tier
        zone = zone
        cidr = cidrsubnet(var.vpc_cidr, var.newbits, tier_index * local.zone_count + zone_index)
      }
    ]
  ])

  parent_prefix = tonumber(split("/", var.vpc_cidr)[1])
  subnet_size   = pow(2, 32 - local.parent_prefix - var.newbits)
}
