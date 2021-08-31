module "platform_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"
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
}

output "storage_lambda_error_alerts_topic_arn" {
  value = module.storage_lambda_error_alerts.alarm_topic_arn
}

module "catalogue_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.catalogue
  }

  account_name = "catalogue"
}

output "catalogue_lambda_error_alerts_topic_arn" {
  value = module.catalogue_lambda_error_alerts.alarm_topic_arn
}

module "workflow_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.workflow
  }

  account_name = "workflow"
}

output "workflow_lambda_error_alerts_topic_arn" {
  value = module.workflow_lambda_error_alerts.alarm_topic_arn
}

module "identity_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.identity
  }

  account_name = "identity"
}

output "identity_lambda_error_alerts_topic_arn" {
  value = module.identity_lambda_error_alerts.alarm_topic_arn
}
