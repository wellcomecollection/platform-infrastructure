module "platform_dlq_to_slack_alerts" {
  source = "./modules/slack_alert_on_sqs_dlq"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"
  infra_bucket = local.platform_infra_bucket

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "platform_dlq_alarm_topic_arn" {
  value = module.platform_dlq_to_slack_alerts.alarm_topic_arn
}

module "catalogue_dlq_to_slack_alerts" {
  source = "./modules/slack_alert_on_sqs_dlq"

  providers = {
    aws = aws.catalogue
  }

  account_name = "catalogue"
  infra_bucket = local.catalogue_infra_bucket

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "catalogue_dlq_alarm_topic_arn" {
  value = module.catalogue_dlq_to_slack_alerts.alarm_topic_arn
}

module "storage_dlq_to_slack_alerts" {
  source = "./modules/slack_alert_on_sqs_dlq"

  providers = {
    aws = aws.storage
  }

  account_name = "storage"
  infra_bucket = local.storage_infra_bucket

  alarm_topic_arn = module.storage_lambda_error_alerts.alarm_topic_arn
}

output "storage_dlq_alarm_topic_arn" {
  value = module.storage_dlq_to_slack_alerts.alarm_topic_arn
}
