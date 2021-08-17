module "platform_dlq_to_slack_alerts" {
  source = "./modules/dlq_to_slack_alerts"

  providers = {
    aws = aws.platform
  }

  infra_bucket = "wellcomecollection-platform-infra"

  alarm_topic_arn = local.lambda_error_alarm_arn

  copy_secrets = false
}

output "platform_dlq_alarm_topic_arn" {
  value = module.platform_dlq_to_slack_alerts.alarm_topic_arn
}

module "catalogue_dlq_to_slack_alerts" {
  source = "./modules/dlq_to_slack_alerts"

  providers = {
    aws = aws.catalogue
  }

  infra_bucket = "wellcomecollection-catalogue-infra-delta"

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "catalogue_dlq_alarm_topic_arn" {
  value = module.catalogue_dlq_to_slack_alerts.alarm_topic_arn
}

module "storage_dlq_to_slack_alerts" {
  source = "./modules/dlq_to_slack_alerts"

  providers = {
    aws = aws.storage
  }

  infra_bucket = "wellcomecollection-storage-infra"

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "storage_dlq_alarm_topic_arn" {
  value = module.storage_dlq_to_slack_alerts.alarm_topic_arn
}
