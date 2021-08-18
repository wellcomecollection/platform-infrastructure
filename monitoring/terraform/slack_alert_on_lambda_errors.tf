module "platform_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"
  infra_bucket = local.platform_infra_bucket
}

output "platform_lambda_error_alerts_topic_arn" {
  value = module.platform_lambda_error_alerts.alarm_topic_arn
}

module "storage_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.storage
  }

  account_name = "storage"
  infra_bucket = local.storage_infra_bucket
}

output "storage_lambda_error_alerts_topic_arn" {
  value = module.storage_lambda_error_alerts.alarm_topic_arn
}