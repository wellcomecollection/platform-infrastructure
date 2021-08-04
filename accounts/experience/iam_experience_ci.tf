resource "aws_iam_role_policy" "experience_ci" {
  role   = module.experience_account.ci_role_name
  policy = data.aws_iam_policy_document.experience_ci_combined.json
}

data "aws_iam_policy_document" "experience_ci_combined" {
  source_policy_documents = [
    module.github_deployment_secrets.secret_access_policy_document_json,
    data.aws_iam_policy_document.experience_ci.json
  ]
}

module "github_deployment_secrets" {
  source = "git::github.com/wellcomecollection/github-deployments-buildkite-plugin.git//secrets-tf?ref=v0.2.4"
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
    sid = "GetBuildSecrets"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_ids["experience"]}:secret:builds/*",
    ]
  }

  statement {
    sid = "GetApiSecrets"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account_ids["experience"]}:secret:catalogue_api/items/*",
    ]
  }
}
