variable "vpc_cidr" {
  description = "Parent IPv4 range to divide."
  type        = string
}

variable "availability_zones" {
  description = "Zones, in allocation order."
  type        = list(string)
}

variable "tiers" {
  description = "Tiers, in allocation order."
  type        = list(string)
}

variable "newbits" {
  description = "Bits added to the parent prefix for each subnet."
  type        = number
}
