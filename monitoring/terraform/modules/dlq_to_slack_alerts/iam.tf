data "aws_iam_policy_document" "read_secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = module.shared_secrets.arns
  }
}

resource "aws_iam_role_policy" "read_secrets" {
  role   = module.lambda.role_name
  policy = data.aws_iam_policy_document.read_secrets.json

  count = var.copy_secrets ? 1 : 0
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
