module "dlq_to_slack_alerts" {
  source = "../slack_alert_lambda"

  name        = "dlq_to_slack_alerts"
  description = "Sends a notification to Slack when there are messages on DLQs"
  topic_name  = "dlq_non_empty_alarm"

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  infra_bucket    = var.infra_bucket
  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

output "alarm_topic_arn" {
  value = module.dlq_to_slack_alerts.alarm_topic_arn
}

data "aws_iam_policy_document" "get_queue_length" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "get_queue_length" {
  role   = module.dlq_to_slack_alerts.role_name
  policy = data.aws_iam_policy_document.get_queue_length.json
}
