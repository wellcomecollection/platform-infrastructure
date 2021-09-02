locals {
  lambda_error_alerts_topic_arn = data.terraform_remote_state.monitoring.outputs.platform_lambda_error_alerts_topic_arn
}