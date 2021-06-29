resource "aws_iam_role_policy" "platform_ci" {
  role   = module.aws_account.ci_role_name
  policy = data.aws_iam_policy_document.platform_ci.json
}

data "aws_iam_policy_document" "platform_ci" {
  dynamic "statement" {
    for_each = [
      "arn:aws:s3:::wellcomecollection-edge-lambdas"
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

  statement {
    actions = [
      "s3:Put*",
    ]

    resources = [
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/weco/internal_model_2.12/*",
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/weco/internal_model_typesafe_2.12/*",
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/weco/source_model_2.12/*",
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/weco/source_model_typesafe_2.12/*",
    ]
  }

  # This slightly unusual clause allows the platform-ci role to assume… itself.
  #
  # This is because Buildkite uses the platform-ci role to run tasks
  # in CI for https://github.com/wellcomecollection/identity, and those CI
  # tasks in turn run Terraform, which has an "assume_role" block for the
  # provider (to match our other Terraform configurations).
  #
  # When Buildkite running as platform-ci tries to assume platform-ci, that
  # isn't allowed by default -- we need to explicitly allow it.
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${local.account_ids.platform}:role/platform-ci",
    ]
  }
}
