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

module "auth0_log_stream_alerts_sns_trigger" {
  source = "../lambda_sns_trigger"

  lambda_arn = module.auth0_log_stream_alerts.arn
  topic_name = "auth0_log_stream_alarm"
}

output "trigger_topic_arn" {
  value = module.auth0_log_stream_alerts_sns_trigger.topic_arn
}
