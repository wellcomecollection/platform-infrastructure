data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  secrets = [
    "monitoring/critical_slack_webhook"
  ]
}

data "aws_iam_policy_document" "read_secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      for secret_id in local.secrets:
      "arn:aws:secretsmanager:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:secret:${secret_id}*"
    ]
  }
}

resource "aws_iam_role_policy" "read_secrets" {
  role   = module.lambda.role_name
  policy = data.aws_iam_policy_document.read_secrets.json
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
  role   = module.lambda.role_name
  policy = data.aws_iam_policy_document.get_queue_length.json
}
