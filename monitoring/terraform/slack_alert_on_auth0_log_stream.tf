module "auth0_log_stream_alerts" {
  source = "./modules/slack_alert_on_auth0_log_stream"

  providers = {
    aws = aws.identity
  }

  alarm_topic_arn = module.identity_lambda_error_alerts.alarm_topic_arn
}

output "auth0_log_stream_lambda_arn" {
  value = module.auth0_log_stream_alerts.lambda_arn
}
