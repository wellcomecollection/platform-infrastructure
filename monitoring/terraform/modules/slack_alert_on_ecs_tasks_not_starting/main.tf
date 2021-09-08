module "alert_on_tasks_not_starting" {
  source = "../slack_alert_lambda"

  name        = "alert_on_tasks_not_starting"
  source_name = "ecs_tasks_cant_start_alert"

  description = "Sends a notification to Slack when ECS tasks are unable to start"
  topic_name  = "ecs_tasks_cant_start"

  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

output "alarm_topic_arn" {
  value = module.alert_on_tasks_not_starting.alarm_topic_arn
}
