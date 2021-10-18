resource "aws_iam_role_policy" "allow_assume_role" {
  role   = module.costs_report_lambda.role_name
  policy = data.aws_iam_policy_document.allow_assume_role.json
}

data "aws_iam_policy_document" "allow_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      module.platform_role.arn,
      module.catalogue_role.arn,
      module.storage_role.arn,
      module.workflow_role.arn,
      module.experience_role.arn,
      module.identity_role.arn,
      module.dam_prototype_role.arn,
      module.digirati_role.arn,
      module.data_role.arn,
      module.reporting_role.arn,
      module.digitisation_role.arn,
    ]
  }
}


resource "aws_iam_role_policy" "allow_get_secrets" {
  role   = module.costs_report_lambda.role_name
  policy = data.aws_iam_policy_document.allow_get_secrets.json
}

data "aws_iam_policy_document" "allow_get_secrets" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:eu-west-1:760097843905:secret:elastic_cloud/api_key*",
      "arn:aws:secretsmanager:eu-west-1:760097843905:secret:elastic_cloud/organisation_id*",
      "arn:aws:secretsmanager:eu-west-1:760097843905:secret:slack/wc-platform-hook*",
    ]
  }
}
