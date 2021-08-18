module "api_gateway_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "api_gateway_to_slack_alerts"
  description = "Sends a notification to Slack when there are 5xx errors from API Gateway"
  topic_name  = "api_gateway_5xx_alarm"

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  infra_bucket    = var.infra_bucket
  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

output "alarm_topic_arn" {
  value = module.api_gateway_to_slack_alerts.alarm_topic_arn
}
