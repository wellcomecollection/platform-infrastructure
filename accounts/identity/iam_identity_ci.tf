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
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:InvokeFunction",
      "lambda:RemovePermission",
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
      "arn:aws:apigateway:eu-west-1::/restapis/*/stages",
      "arn:aws:apigateway:eu-west-1::/restapis/*/stages/*"
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
}
