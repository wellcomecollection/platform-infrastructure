locals {
  gateway_server_error_alarm_arn = module.platform_dlq_to_slack_alerts.alarm_topic_arn
  lambda_error_alarm_arn         = local.shared_infra["lambda_error_alarm_arn"]
  dlq_alarm_arn                  = module.platform_dlq_to_slack_alerts.alarm_topic_arn

  admin_cidr_ingress = data.aws_ssm_parameter.admin_cidr_ingress.value

  bucket_alb_logs_id = local.shared_infra["bucket_alb_logs_id"]

  namespace = "monitoring"

  vpc_id          = local.platform_vpcs["monitoring_vpc_delta_id"]
  private_subnets = local.platform_vpcs["monitoring_vpc_delta_private_subnets"]
  public_subnets  = local.platform_vpcs["monitoring_vpc_delta_public_subnets"]

  catalogue_infra_bucket = "wellcomecollection-catalogue-infra-delta"
  identity_infra_bucket  = "wellcomecollection-identity-experience-infra"
  platform_infra_bucket  = "wellcomecollection-platform-infra"
  storage_infra_bucket   = "wellcomecollection-storage-infra"
  workflow_infra_bucket  = "wellcomecollection-workflow-infra"
}


data "aws_ssm_parameter" "admin_cidr_ingress" {
  name = "/infra_critical/config/prod/admin_cidr_ingress"
}