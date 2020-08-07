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
      local.ci_role_arn["catalogue"]
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

  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      local.infra_bucket_arn,
      "${local.infra_bucket_arn}/*",
    ]
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