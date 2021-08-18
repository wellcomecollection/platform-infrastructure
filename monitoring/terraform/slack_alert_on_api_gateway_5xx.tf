module "catalogue_api_gateway_alerts" {
  source = "./modules/slack_alert_on_api_gateway_5xx"

  providers = {
    aws = aws.catalogue
  }

  account_name = "catalogue"
  infra_bucket = local.catalogue_infra_bucket

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "catalogue_api_gateway_alerts_topic_arn" {
  value = module.catalogue_api_gateway_alerts.alarm_topic_arn
}

module "storage_api_gateway_alerts" {
  source = "./modules/slack_alert_on_api_gateway_5xx"

  providers = {
    aws = aws.storage
  }

  account_name = "storage"
  infra_bucket = local.storage_infra_bucket

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "storage_api_gateway_alerts_topic_arn" {
  value = module.storage_api_gateway_alerts.alarm_topic_arn
}

module "identity_api_gateway_alerts" {
  source = "./modules/slack_alert_on_api_gateway_5xx"

  providers = {
    aws = aws.identity
  }

  account_name = "identity"
  infra_bucket = local.identity_infra_bucket

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "identity_api_gateway_alerts_topic_arn" {
  value = module.identity_api_gateway_alerts.alarm_topic_arn
}
