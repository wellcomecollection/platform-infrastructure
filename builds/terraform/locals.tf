data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  infra_bucket_arn = local.shared_infra["infra_bucket_arn"]
  infra_bucket_id  = local.shared_infra["infra_bucket"]

  platform_read_only_role_arn = local.platform_accounts["platform_read_only_role_arn"]
  account_ci_role_arn_map     = local.platform_accounts["ci_role_arn"]

  ci_agent_role_name      = "ci-agent"
  ci_nano_agent_role_name = "${local.ci_agent_role_name}-nano"

  ci_vpc_id              = local.platform_vpcs["ci_vpc_id"]
  ci_vpc_private_subnets = local.platform_vpcs["ci_vpc_private_subnets"]

  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
}