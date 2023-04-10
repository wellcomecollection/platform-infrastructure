module "dlq_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "dlq_to_slack_alerts"
  source_name = "metric_to_slack_alert"

  description = "Sends a notification to Slack when there are messages on DLQs"

  environment_variables = {
    STR_SINGLE_ERROR_MESSAGE      = "There is 1 message on the DLQ"
    STR_MULTIPLE_ERROR_MESSAGE    = "There are {error_count} messages on the DLQ"
    STR_ALARM_SLUG                = "sqs-dlq-not-empty"
    STR_ALARM_LEVEL               = "warning"
    CONTEXT_URL_TEMPLATE          = "${var.account_name}-dlq-alerts"
    INT_SUPERPLURAL_THRESHOLD     = 10000
    STR_SUPERPLURAL_ERROR_MESSAGE = "There is a very large number of messages ({error_count}) on the DLQ. See https://github.com/wellcomecollection/catalogue-pipeline/tree/main/docs/troubleshooting for help"
  }

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

moved {
  from = module.dlq_to_slack_alerts.aws_sns_topic.topic
  to   = module.dlq_to_slack_alerts_sns_trigger.aws_sns_topic.topic
}

moved {
  from = module.dlq_to_slack_alerts.aws_lambda_permission.allow_sns_trigger
  to   = module.dlq_to_slack_alerts_sns_trigger.aws_lambda_permission.allow_sns_trigger
}

moved {
  from = module.dlq_to_slack_alerts.aws_sns_topic_subscription.topic_lambda
  to   = module.dlq_to_slack_alerts_sns_trigger.aws_sns_topic_subscription.sns_to_lambda
}

module "dlq_to_slack_alerts_sns_trigger" {
  source = "../lambda_sns_trigger"

  lambda_arn = module.dlq_to_slack_alerts.arn
  topic_name = "${var.account_name}_dlq_non_empty_alarm"
}

output "trigger_topic_arn" {
  value = module.dlq_to_slack_alerts_sns_trigger.topic_arn
}
