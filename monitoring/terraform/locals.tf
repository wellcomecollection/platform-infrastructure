locals {
  admin_cidr_ingress = data.aws_ssm_parameter.admin_cidr_ingress.value

  namespace = "monitoring"

  vpc_id          = local.platform_vpcs["monitoring_vpc_delta_id"]
  private_subnets = local.platform_vpcs["monitoring_vpc_delta_private_subnets"]
  public_subnets  = local.platform_vpcs["monitoring_vpc_delta_public_subnets"]
}


data "aws_ssm_parameter" "admin_cidr_ingress" {
  name = "/infra_critical/config/prod/admin_cidr_ingress"
}