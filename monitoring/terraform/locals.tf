locals {
  gateway_server_error_alarm_arn = local.shared_infra["gateway_server_error_alarm_arn"]
  lambda_error_alarm_arn         = local.shared_infra["lambda_error_alarm_arn"]
  dlq_alarm_arn                  = local.shared_infra["dlq_alarm_arn"]

  admin_cidr_ingress = data.terraform_remote_state.infra_critical.outputs.admin_cidr_ingress

  bucket_alb_logs_id = local.shared_infra["bucket_alb_logs_id"]

  cloudfront_errors_topic_arn = data.terraform_remote_state.loris.outputs.cloudfront_errors_topic_arn

  namespace = "monitoring"

  vpc_id          = local.platform_vpcs["monitoring_vpc_delta_id"]
  private_subnets = local.platform_vpcs["monitoring_vpc_delta_private_subnets"]
  public_subnets  = local.platform_vpcs["monitoring_vpc_delta_public_subnets"]
}
