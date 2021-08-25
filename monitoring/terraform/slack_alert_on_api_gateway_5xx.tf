module "catalogue_api_gateway_alerts" {
  source = "./modules/slack_alert_on_api_gateway_5xx"

  providers = {
    aws = aws.catalogue
  }

  account_name = "catalogue"

  alarm_topic_arn = module.catalogue_lambda_error_alerts.alarm_topic_arn
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

  alarm_topic_arn = module.storage_lambda_error_alerts.alarm_topic_arn
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

  alarm_topic_arn = module.identity_lambda_error_alerts.alarm_topic_arn
}

output "identity_api_gateway_alerts_topic_arn" {
  value = module.identity_api_gateway_alerts.alarm_topic_arn
}
