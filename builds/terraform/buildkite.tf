data "aws_iam_role" "buildkite_agent" {
  name = "buildkite-agent"
}

resource "aws_iam_role_policy" "buildkite_agent" {
  policy = data.aws_iam_policy_document.ci_permissions.json
  role = data.aws_iam_role.buildkite_agent.id
}

data "aws_iam_policy_document" "ci_permissions" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [
      local.platform_read_only_role_arn,
      local.ci_role_arn["platform"],
      local.ci_role_arn["catalogue"],
      local.ci_role_arn["storage"]
    ]
  }

  statement {
    actions = [
      "ecr:*",
    ]

    resources = [
      "*",
    ]
  }

  dynamic "statement" {
    for_each = [
      "json",
      "storage",
      "monitoring",
      "messaging",
      "fixtures",
      "typesafe_app"
    ]

    content {
      actions = [
        "s3:*"
      ]

      resources = [
        "${aws_s3_bucket.releases.arn}/uk/ac/wellcome/${statement.value}_2.12/*",
        "${aws_s3_bucket.releases.arn}/uk/ac/wellcome/${statement.value}_typesafe_2.12/*",
      ]
    }
  }

  # Deploy front-end static websites
  dynamic "statement" {
    for_each = [
      "arn:aws:s3:::dash.wellcomecollection.org",
      "arn:aws:s3:::cardigan.wellcomecollection.org"
    ]

    content {
      actions = [
        "s3:*"
      ]

      resources = [
        statement.value,
        "${statement.value}/*",
      ]
    }
  }

  # Deploy front-end toggles
  statement {
    actions = [
      "s3:List*",
      "s3:Put*",
    ]

    resources = [
      "arn:aws:s3:::toggles.wellcomecollection.org/toggles.json",
    ]
  }

  # Deploy front-end edge lambdas
  statement {
    actions = [
      "s3:List*",
      "s3:Put*",
    ]

    resources = [
      "arn:aws:s3:::weco-lambdas/edge_lambda_origin.zip",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:builds/*",
    ]
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}