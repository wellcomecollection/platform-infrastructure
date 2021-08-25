module "experience_cloudfront_alerts" {
  source = "./modules/slack_alert_on_cloudfront_errors"

  providers = {
    aws = aws.experience
  }

  account_name = "experience"
  infra_bucket = local.experience_infra_bucket

  alarm_topic_arn = module.experience_lambda_error_alerts.alarm_topic_arn
}

output "experience_cloudfront_alerts_topic_arn" {
  value = module.experience_cloudfront_alerts.alarm_topic_arn
}
