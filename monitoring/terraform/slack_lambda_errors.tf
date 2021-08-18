module "platform_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"
  infra_bucket = "wellcomecollection-platform-infra"

  alarm_topic_arn = module.platform_lambda_error_alerts.alarm_topic_arn
}

output "platform_lambda_error_alerts_topic_arn" {
  value = module.platform_lambda_error_alerts.alarm_topic_arn
}
