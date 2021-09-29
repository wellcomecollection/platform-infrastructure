# This alarm is firing repeatedly and we're not fixing it, so disable
# it until we're able to investigate these errors properly.  Otherwise they're
# just noise in the Slack channel.
/*module "experience_cloudfront_alerts" {
  source = "./modules/slack_alert_on_cloudfront_errors"

  providers = {
    aws = aws.experience_cloudfront
  }

  account_name = "experience"
}

output "experience_cloudfront_alerts_topic_arn" {
  value = module.experience_cloudfront_alerts.alarm_topic_arn
}*/
