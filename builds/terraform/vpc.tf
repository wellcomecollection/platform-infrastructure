module "ecr_dkr_vpc_endpoint" {
  source = "../../accounts/modules/interface_endpoint"

  service = "ecr.dkr"
  vpc_id  = local.ci_vpc_id

  security_group_ids = [
    # buildkite-elastic
    "sg-0b5a4d52331945b7e",
  ]

  subnet_ids = local.ci_vpc_private_subnets
}

module "ecr_api_vpc_endpoint" {
  source = "../../accounts/modules/interface_endpoint"

  service = "ecr.api"
  vpc_id  = local.ci_vpc_id

  security_group_ids = [
    # buildkite-elastic
    "sg-0b5a4d52331945b7e",
  ]

  subnet_ids = local.ci_vpc_private_subnets
}
