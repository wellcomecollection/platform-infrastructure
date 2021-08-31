module "dlq_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "dlq_to_slack_alerts"
  source_name = "metric_to_slack_alert"

  description = "Sends a notification to Slack when there are messages on DLQs"
  topic_name  = "dlq_non_empty_alarm"

  environment_variables = {
    STR_SINGLE_ERROR_MESSAGE   = "There is 1 message on the DLQ"
    STR_MULTIPLE_ERROR_MESSAGE = "There are {error_count} messages on the DLQ"
    STR_ALARM_SLUG             = "sqs-dlq-not-empty"
    STR_ALARM_LEVEL            = "warning"
  }

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

output "alarm_topic_arn" {
  value = module.dlq_to_slack_alerts.alarm_topic_arn
}
