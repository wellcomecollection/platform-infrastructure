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
        "s3:*",
      ]
      resources = [
        "${aws_s3_bucket.releases.arn}/uk/ac/wellcome/${statement.value}_2.12/*",
        "${aws_s3_bucket.releases.arn}/uk/ac/wellcome/${statement.value}_typesafe_2.12/*",
      ]
    }
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      aws_s3_bucket.releases.arn,
      "${aws_s3_bucket.releases.arn}/*",
    ]
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}