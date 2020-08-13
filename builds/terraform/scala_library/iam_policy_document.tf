data "aws_iam_policy_document" "travis_permissions" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = var.assumable_ci_roles
  }

  dynamic "statement" {
    for_each = var.lib_names
    content {
      actions = [
        "s3:*",
      ]
      resources = [
        "${var.bucket_arn}/uk/ac/wellcome/${statement.value}_2.12/*",
        "${var.bucket_arn}/uk/ac/wellcome/${statement.value}_typesafe_2.12/*",
      ]
    }
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      var.bucket_arn,
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${var.bucket_arn}/uk/ac/wellcome/*",
    ]
  }

  statement {
    actions = [
      "ssm:PutParameter",
    ]

    resources = [
      "arn:aws:ssm:eu-west-1:${local.account_id}:parameter/releases/*",
    ]
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
