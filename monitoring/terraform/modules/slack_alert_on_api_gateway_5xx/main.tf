module "api_gateway_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "api_gateway_to_slack_alerts"
  source_name = "metric_to_slack_alert"

  description = "Sends a notification to Slack when there are 5xx errors from API Gateway"
  topic_name  = "api_gateway_5xx_alarm"

  environment_variables = {
    STR_SINGLE_ERROR_MESSAGE   = "There was 1 error in the API"
    STR_MULTIPLE_ERROR_MESSAGE = "There were {error_count} errors in the API"
    STR_ALARM_SLUG             = "api-gateway-5xx-alarm"
    STR_ALARM_LEVEL            = "error"
    CONTEXT_URL_TEMPLATE       = "${var.account_name}-api-gateway-5xx-errors"
  }

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

output "alarm_topic_arn" {
  value = module.api_gateway_to_slack_alerts.alarm_topic_arn
}
