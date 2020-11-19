resource "aws_iam_role_policy" "identity_ci" {
  role   = module.identity_account.ci_role_name
  policy = data.aws_iam_policy_document.identity_ci.json
}

data "aws_iam_policy_document" "identity_ci" {

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
}
