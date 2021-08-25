module "cloudfront_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "cloudfront_to_slack_alerts"
  source_name = "metric_to_slack_alert"

  description = "Sends a notification to Slack when there are 5xx errors from CloudFront"
  topic_name  = "cloudfront_5xx_alarm"

  environment_variables = {
    STR_SINGLE_ERROR_MESSAGE   = "There was 1 error in CloudFront"
    STR_MULTIPLE_ERROR_MESSAGE = "There were {error_count} errors in CloudFront"
    STR_ALARM_SLUG             = "api-gateway-5xx-alarm"
    STR_ALARM_LEVEL            = "error"
  }

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  infra_bucket    = var.infra_bucket
  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

output "alarm_topic_arn" {
  value = module.cloudfront_to_slack_alerts.alarm_topic_arn
}
