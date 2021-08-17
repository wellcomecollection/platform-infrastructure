module "catalogue_api_gateway_alerts" {
  source = "./modules/api_gateway_to_slack_alerts"

  providers = {
    aws = aws.catalogue
  }

  account_name = "catalogue"
  infra_bucket = "wellcomecollection-catalogue-infra-delta"

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "catalogue_api_gateway_alerts_topic_arn" {
  value = module.storage_api_gateway_alerts.alarm_topic_arn
}

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

module "identity_api_gateway_alerts" {
  source = "./modules/api_gateway_to_slack_alerts"

  providers = {
    aws = aws.identity
  }

  account_name = "identity"
  infra_bucket = "wellcomecollection-identity-experience-infra"

  alarm_topic_arn = local.lambda_error_alarm_arn
}

output "identity_api_gateway_alerts_topic_arn" {
  value = module.identity_api_gateway_alerts.alarm_topic_arn
}
