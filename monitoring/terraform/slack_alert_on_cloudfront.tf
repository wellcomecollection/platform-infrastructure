module "experience_cloudfront_alerts" {
  source = "./modules/slack_alert_on_cloudfront_errors"

  providers = {
    aws = aws.experience_cloudfront
  }

  context_url_template = "experience-cloudfront-errors"

  account_name = "experience"
}

output "experience_cloudfront_alerts_topic_arn" {
  value = module.experience_cloudfront_alerts.alarm_topic_arn
}
