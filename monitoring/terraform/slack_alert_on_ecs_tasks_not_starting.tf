module "platform_alert_on_ecs_tasks_not_starting" {
  source = "./modules/slack_alert_on_ecs_tasks_not_starting"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"

  alarm_topic_arn = module.platform_lambda_error_alerts.trigger_topic_arn
}

module "storage_alert_on_ecs_tasks_not_starting" {
  source = "./modules/slack_alert_on_ecs_tasks_not_starting"

  providers = {
    aws = aws.storage
  }

  account_name = "storage"

  alarm_topic_arn = module.storage_lambda_error_alerts.trigger_topic_arn
}

module "catalogue_alert_on_ecs_tasks_not_starting" {
  source = "./modules/slack_alert_on_ecs_tasks_not_starting"

  providers = {
    aws = aws.catalogue
  }

  account_name = "catalogue"

  alarm_topic_arn = module.catalogue_lambda_error_alerts.trigger_topic_arn
}

module "experience_alert_on_ecs_tasks_not_starting" {
  source = "./modules/slack_alert_on_ecs_tasks_not_starting"

  providers = {
    aws = aws.experience
  }

  account_name = "experience"

  alarm_topic_arn = module.experience_lambda_error_alerts.trigger_topic_arn
}
