module "cloudfront_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "cloudfront_to_slack_alerts"
  source_name = "metric_to_slack_alert"

  description = "Sends a notification to Slack when there are 5xx errors from CloudFront"

  environment_variables = {
    STR_SINGLE_ERROR_MESSAGE   = "1% of requests in CloudFront were 5xx errors"
    STR_MULTIPLE_ERROR_MESSAGE = "{error_count:0.2f}% of requests in CloudFront were 5xx errors"
    STR_ALARM_SLUG             = "cloudfront-5xx-alarm"
    STR_ALARM_LEVEL            = "error"
    CONTEXT_URL_TEMPLATE       = var.context_url_template
  }

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  account_name    = var.account_name
  alarm_topic_arn = var.lambda_alarm_topic_arn
}

module "cloudfront_to_slack_alerts_sns_trigger" {
  source = "../lambda_sns_trigger"

  lambda_arn = module.cloudfront_to_slack_alerts.arn
  topic_name = "${var.account_name}_cloudfront_5xx_alarm"
}

output "trigger_topic_arn" {
  value = module.cloudfront_to_slack_alerts_sns_trigger.topic_arn
}
