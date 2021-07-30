module "lambda_post_to_slack" {
  source = "../modules/lambda"

  s3_bucket = var.infra_bucket
  s3_key    = "lambdas/monitoring/post_to_slack.zip"

  name        = "post_to_slack"
  description = "Post notification to Slack when an alarm is triggered"
  timeout     = 10

  environment_variables = {
    CRITICAL_SLACK_WEBHOOK    = var.critical_slack_webhook
    NONCRITICAL_SLACK_WEBHOOK = var.non_critical_slack_webhook
    BITLY_ACCESS_TOKEN        = var.bitly_access_token
  }

  alarm_topic_arn = var.lambda_error_alarm_arn

  log_retention_in_days = 30
}

module "trigger_post_to_slack_dlqs_not_empty" {
  source = "../modules/lambda_trigger_sns"

  lambda_function_name = module.lambda_post_to_slack.function_name
  lambda_function_arn  = module.lambda_post_to_slack.arn
  sns_trigger_arn      = var.dlq_alarm_arn
}

module "trigger_post_to_slack_server_error_gateway" {
  source = "../modules/lambda_trigger_sns"

  lambda_function_name = module.lambda_post_to_slack.function_name
  lambda_function_arn  = module.lambda_post_to_slack.arn
  sns_trigger_arn      = var.gateway_server_error_alarm_arn
}

module "trigger_post_to_slack_lambda_error" {
  source = "../modules/lambda_trigger_sns"

  lambda_function_name = module.lambda_post_to_slack.function_name
  lambda_function_arn  = module.lambda_post_to_slack.arn
  sns_trigger_arn      = var.lambda_error_alarm_arn
}
