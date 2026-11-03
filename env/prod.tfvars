project            = "acme"
environment        = "prod"
owner              = "platform-team"
vpc_cidr           = "10.40.0.0/16"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

extra_tags = {
  CostCenter = "cc-1042"
}
