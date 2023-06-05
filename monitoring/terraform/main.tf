module "monitoring-271118" {
  source = "./stack"

  namespace = "monitoring-271118"
  vpc_id    = local.vpc_id

  efs_id                           = aws_efs_file_system.efs.id
  efs_security_group_id            = aws_security_group.efs_security_group.id
  ec_privatelink_security_group_id = local.ec_privatelink_sg_id

  domain = "monitoring.wellcomecollection.org"

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  infra_bucket       = local.infra_bucket
  key_name           = local.key_name
  aws_region         = var.aws_region
  admin_cidr_ingress = local.admin_cidr_ingress

  # grafana

  grafana_admin_user        = local.grafana_admin_user
  grafana_anonymous_role    = local.grafana_anonymous_role
  grafana_admin_password    = local.grafana_admin_password
  grafana_anonymous_enabled = local.grafana_anonymous_enabled

  providers = {
    aws.dns = aws.dns
  }
}
