resource "aws_iam_role_policy" "identity_ci" {
  role   = module.identity_account.ci_role_name
  policy = data.aws_iam_policy_document.identity_ci.json
}

data "aws_iam_policy_document" "identity_ci" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:AddPermission",
      "lambda:CreateAlias",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetAlias",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetPolicy",
      "lambda:InvokeFunction",
      "lambda:RemovePermission",
      "lambda:UpdateAlias",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "arn:aws:lambda:eu-west-1:${local.account_ids.identity}:function:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "apigateway:*"
    ]

    resources = [
      "arn:aws:apigateway:eu-west-1::*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
      "s3:Delete*"
    ]
    resources = [
      "arn:aws:s3:::identity-dist",
      "arn:aws:s3:::identity-dist/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:Get*"
    ]
    resources = [
      "arn:aws:s3:::identity-remote-state",
      "arn:aws:s3:::identity-remote-state/*",
      "arn:aws:s3:::identity-static-remote-state",
      "arn:aws:s3:::identity-static-remote-state/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*"
    ]
    resources = [
      "arn:aws:s3:::identity-public-swagger-ui-v1-stage",
      "arn:aws:s3:::identity-public-swagger-ui-v1-stage/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_ids.identity}:distribution/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:UpdateService"
    ]
    resources = [
      "arn:aws:ecs:eu-west-1:${local.account_ids.identity}:service/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_ids.identity}:role/identity-ecs-task-role-stage",
      "arn:aws:iam::${local.account_ids.identity}:role/identity-ecs-execution-role-stage"
    ]
  }

  # This slightly unusual clause allows the identity-ci role to assume… itself.
  #
  # This is because Buildkite uses the identity-ci role to run tasks
  # in CI for https://github.com/wellcomecollection/identity, and those CI
  # tasks in turn run Terraform, which has an "assume_role" block for the
  # provider (to match our other Terraform configurations).
  #
  # When Buildkite running as identity-ci tries to assume identity-ci, that
  # isn't allowed by default -- we need to explicitly allow it.
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${local.account_ids.identity}:role/identity-ci",
    ]
  }
}
