module "cloudfront_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "cloudfront_to_slack_alerts"
  source_name = "metric_to_slack_alert"

  description = "Sends a notification to Slack when there are 5xx errors from CloudFront"
  topic_name  = "cloudfront_5xx_alarm"

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
  alarm_topic_arn = module.lambda_error_alerts.trigger_topic_arn
}

output "trigger_topic_arn" {
  value = module.cloudfront_to_slack_alerts.trigger_topic_arn
}

# Because CloudFront lives in us-east-1 but the rest of our services
# are in eu-west-1, we create a Lambda to alert on failures in the
# CloudFront alerting Lambda within that region.
#
# This avoids the complication of cross-region alerting and the like.
module "slack_secrets" {
  source = "../../../../critical/modules/secrets/distributed"

  secrets = {
    noncritical_slack_webhook = "monitoring/critical_slack_webhook"
  }
}

module "lambda_error_alerts" {
  source = "../slack_alert_on_lambda_error"

  account_name = var.account_name
}
