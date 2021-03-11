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
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/uk/ac/wellcome/internal_model_2.12/*",
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/uk/ac/wellcome/internal_model_typesafe_2.12/*",
    ]
  }
}
