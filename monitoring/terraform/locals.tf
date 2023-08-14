locals {
  namespace = "monitoring"

  vpc_id               = local.platform_vpcs["monitoring_vpc_delta_id"]
  private_subnets      = local.platform_vpcs["monitoring_vpc_delta_private_subnets"]
  public_subnets       = local.platform_vpcs["monitoring_vpc_delta_public_subnets"]
  ec_privatelink_sg_id = local.shared_infra["ec_monitoring_privatelink_sg_id"]
}
