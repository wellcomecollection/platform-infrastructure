resource "aws_iam_role_policy" "catalogue_ci" {
  role   = module.catalogue_account.ci_role_name
  policy = data.aws_iam_policy_document.catalogue_ci.json
}

data "aws_iam_policy_document" "catalogue_ci" {
  # Secrets required for internal model checker to run
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "${local.secrets_base_arn}elasticsearch/pipeline_storage_*",
    ]
  }
}