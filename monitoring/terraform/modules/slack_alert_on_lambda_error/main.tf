module "lambda_errors_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "lambda_errors_to_slack_alerts"
  description = "Sends a notification to Slack when a Lambda function fails"
  topic_name  = "lambda_error_alarm"

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  infra_bucket    = var.infra_bucket
  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

output "alarm_topic_arn" {
  value = module.lambda_errors_to_slack_alerts.alarm_topic_arn
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
