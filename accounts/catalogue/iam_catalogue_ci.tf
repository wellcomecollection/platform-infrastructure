resource "aws_iam_role_policy" "catalogue_ci" {
  role   = module.catalogue_account.ci_role_name
  policy = data.aws_iam_policy_document.catalogue_ci.json
}

data "aws_iam_policy_document" "catalogue_ci" {
  # Secrets required for diff_tool to run
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    # TODO: We're changing the secrets this tool reads as part of removing
    # CCR from the catalogue (see https://github.com/wellcomecollection/platform/issues/5430).
    #
    # At time of writing (February 2022) we have both old and new secrets
    # here, but at some point we should remove the old (catalogue_api*) secrets.
    resources = [
      "${local.secrets_base_arn}elasticsearch/pipeline_storage*",
      "${local.secrets_base_arn}elasticsearch/catalogue_api*",
      "${local.secrets_base_arn}elasticsearch/pipeline_storage_*",
    ]
  }
}
