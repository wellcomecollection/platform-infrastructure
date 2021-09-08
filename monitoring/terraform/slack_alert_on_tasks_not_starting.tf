module "platform_alert_on_ecs_tasks_not_starting" {
  source = "./modules/slack_alert_on_ecs_tasks_not_starting"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"

  alarm_topic_arn = module.platform_lambda_error_alerts.alarm_topic_arn
}
