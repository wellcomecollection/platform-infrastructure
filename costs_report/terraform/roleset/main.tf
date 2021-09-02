variable "account_name" {
  type = string
}

variable "lambda_task_role_arn" {
  type = string
}

resource "aws_iam_role" "role" {
  name               = "${var.account_name}-costs_report_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  max_session_duration = 3600
}

output "arn" {
  value = aws_iam_role.role.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        var.lambda_task_role_arn,
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "allow_get_costs" {
  role   = aws_iam_role.role.name
  policy = data.aws_iam_policy_document.allow_get_costs.json
}

data "aws_iam_policy_document" "allow_get_costs" {
  statement {
    effect = "Allow"

    actions = [
      "ce:GetCostAndUsage",
    ]

    resources = [
      "*",
    ]
  }
}
