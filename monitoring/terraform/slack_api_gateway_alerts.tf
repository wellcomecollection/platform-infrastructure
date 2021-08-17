module "storage_api_gateway_alerts" {
  source = "./modules/api_gateway_to_slack_alerts"

  providers = {
    aws = aws.storage
  }

  account_name = "storage"
  infra_bucket = "wellcomecollection-storage-infra"

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "storage_api_gateway_alerts_topic_arn" {
  value = module.storage_api_gateway_alerts.alarm_topic_arn
}
