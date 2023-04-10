module "auth0_log_stream_alerts" {
  source = "../slack_alert_lambda"

  name        = "auth0_log_stream_alerts"
  source_name = "auth0_log_stream_alert"

  description = "Sends a notification to Slack when the Auth0 log stream contains an unexpected error"

  alarm_topic_arn = var.alarm_topic_arn

  secrets = [
    "monitoring/critical_slack_webhook"
  ]

  account_name = "identity"
}

moved {
  from = module.auth0_log_stream_alerts.aws_sns_topic.topic
  to   = module.auth0_log_stream_alerts_sns_trigger.aws_sns_topic.topic
}

moved {
  from = module.auth0_log_stream_alerts.aws_lambda_permission.allow_sns_trigger
  to   = module.auth0_log_stream_alerts_sns_trigger.aws_lambda_permission.allow_sns_trigger
}

moved {
  from = module.auth0_log_stream_alerts.aws_sns_topic_subscription.topic_lambda
  to   = module.auth0_log_stream_alerts_sns_trigger.aws_sns_topic_subscription.sns_to_lambda
}

module "auth0_log_stream_alerts_sns_trigger" {
  source = "../lambda_sns_trigger"

  lambda_arn = module.auth0_log_stream_alerts.arn
  topic_name = "auth0_log_stream_alarm"
}

output "trigger_topic_arn" {
  value = module.auth0_log_stream_alerts_sns_trigger.topic_arn
}
