module "monitoring-271118" {
  source = "./stack"

  grafana_version = "9.5.2"
  namespace       = "monitoring-271118"

  efs_id                           = aws_efs_file_system.efs.id
  efs_security_group_id            = aws_security_group.efs_security_group.id
  ec_privatelink_security_group_id = local.ec_privatelink_sg_id

  domain = "monitoring.wellcomecollection.org"

  vpc_id          = local.vpc_id
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  providers = {
    aws.dns = aws.dns
  }
}
