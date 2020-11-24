resource "aws_iam_role_policy" "identity_ci" {
  role   = module.identity_account.ci_role_name
  policy = data.aws_iam_policy_document.identity_ci.json
}

data "aws_iam_policy_document" "identity_ci" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:CreateAlias",
      "lambda:GetFunction",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:UpdateFunctionCode",
      "lambda:GetFunctionConfiguration",
      "lambda:UpdateFunctionConfiguration",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:InvokeFunction"
    ]

    resources = [
      "arn:aws:lambda:::function:identity-api-*",
      "arn:aws:lambda:::function:identity-authorizer-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "apigateway:*"
    ]

    resources = [
      "arn:aws:apigateway:::/restapis/*/stages",
      "arn:aws:apigateway:::/restapis/*/stages/*"
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
