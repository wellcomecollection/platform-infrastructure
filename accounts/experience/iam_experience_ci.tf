resource "aws_iam_role_policy" "experience_ci" {
  role   = module.experience_account.ci_role_name
  policy = data.aws_iam_policy_document.experience_ci.json
}

data "aws_iam_policy_document" "experience_ci" {
  # Deploy front-end static websites
  dynamic "statement" {
    for_each = [
      "arn:aws:s3:::dash.wellcomecollection.org",
      "arn:aws:s3:::cardigan.wellcomecollection.org",
      "arn:aws:s3:::toggles.wellcomecollection.org",
      "arn:aws:s3:::weco-lambdas"
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
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_ids["experience"]}:secret:builds/*",
    ]
  }
}
