module "platform_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"
}

output "platform_lambda_error_alerts_topic_arn" {
  value = module.platform_lambda_error_alerts.trigger_topic_arn
}

module "storage_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.storage
  }

  account_name = "storage"
}

output "storage_lambda_error_alerts_topic_arn" {
  value = module.storage_lambda_error_alerts.trigger_topic_arn
}

module "catalogue_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.catalogue
  }

  account_name = "catalogue"
}

output "catalogue_lambda_error_alerts_topic_arn" {
  value = module.catalogue_lambda_error_alerts.trigger_topic_arn
}

module "workflow_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.workflow
  }

  account_name = "workflow"
}

output "workflow_lambda_error_alerts_topic_arn" {
  value = module.workflow_lambda_error_alerts.trigger_topic_arn
}

module "identity_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.identity
  }

  account_name = "identity"
}

output "identity_lambda_error_alerts_topic_arn" {
  value = module.identity_lambda_error_alerts.trigger_topic_arn
}

module "experience_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.experience
  }

  account_name = "experience"
}

output "experience_lambda_error_alerts_topic_arn" {
  value = module.experience_lambda_error_alerts.trigger_topic_arn
}

module "experience_cloudfront_lambda_error_alerts" {
  source = "./modules/slack_alert_on_lambda_error"

  providers = {
    aws = aws.experience_cloudfront
  }

  # We need to add a suffix here, so this doesn't conflict with the
  # "alert on Lambda errors" Lambda that lives in eu-west-1 in this account.
  account_name = "experience_useast1"
}

output "experience_cloudfront_error_alerts_topic_arn" {
  value = module.experience_cloudfront_lambda_error_alerts.trigger_topic_arn
}
