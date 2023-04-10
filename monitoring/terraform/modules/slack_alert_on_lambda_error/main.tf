module "lambda_errors_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "lambda_errors_to_slack_alerts"
  description = "Sends a notification to Slack when a Lambda function fails"

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  account_name    = var.account_name
  alarm_topic_arn = module.lambda_errors_to_slack_alerts_sns_trigger.topic_arn
}

moved {
  from = module.lambda_errors_to_slack_alerts.aws_sns_topic.topic
  to   = module.lambda_errors_to_slack_alerts_sns_trigger.aws_sns_topic.topic
}

moved {
  from = module.lambda_errors_to_slack_alerts.aws_lambda_permission.allow_sns_trigger
  to   = module.lambda_errors_to_slack_alerts_sns_trigger.aws_lambda_permission.allow_sns_trigger
}

moved {
  from = module.lambda_errors_to_slack_alerts.aws_sns_topic_subscription.topic_lambda
  to   = module.lambda_errors_to_slack_alerts_sns_trigger.aws_sns_topic_subscription.sns_to_lambda
}

module "lambda_errors_to_slack_alerts_sns_trigger" {
  source = "../lambda_sns_trigger"

  lambda_arn = module.lambda_errors_to_slack_alerts.arn
  topic_name = "${var.account_name}_lambda_error_alarm"
}

output "trigger_topic_arn" {
  value = module.lambda_errors_to_slack_alerts_sns_trigger.topic_arn
}

data "aws_iam_policy_document" "cloudwatch_allow_filterlogs" {
  statement {
    actions = [
      "logs:FilterLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "get_cloudwatch_logs" {
  role   = module.lambda_errors_to_slack_alerts.role_name
  policy = data.aws_iam_policy_document.cloudwatch_allow_filterlogs.json
}
