data "aws_iam_role" "buildkite_agent" {
  name = "buildkite-agent"
}

resource "aws_iam_role_policy" "buildkite_agent" {
  policy = data.aws_iam_policy_document.ci_permissions.json
  role = data.aws_iam_role.buildkite_agent.id

  provider = "aws"
}

data "aws_iam_policy_document" "ci_permissions" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [
      local.platform_read_only_role_arn,
      local.ci_role_arn["platform"],
      local.ci_role_arn["catalogue"],
      local.ci_role_arn["storage"],
      local.ci_role_arn["experience"]
    ]
  }

  # Deploy images to ECR (platform account)
  statement {
    actions = [
      "ecr:*",
    ]

    resources = [
      "*",
    ]
  }

  # Retrieve build secrets
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:builds/*",
    ]
  }

  # Publish scala libraries
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
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}