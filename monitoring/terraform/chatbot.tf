resource "aws_iam_role" "catalogue_chatbot" {
  assume_role_policy = data.aws_iam_policy_document.catalogue_chatbot_assume_role_policy.json
  provider           = aws.catalogue
  name               = "catalogue-chatbot"
}

data "aws_iam_policy_document" "catalogue_chatbot_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["chatbot.amazonaws.com"]
      type        = "Service"
    }
  }
  provider = aws.catalogue
}

resource "aws_iam_role_policy" "catalogue_chatbot" {
  policy   = data.aws_iam_policy_document.catalogue_chatbot.json
  role     = aws_iam_role.catalogue_chatbot.name
  provider = aws.catalogue
}

data "aws_iam_policy_document" "catalogue_chatbot" {
  statement {
    actions = [
      "autoscaling:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Get*",
      "logs:List*",
      "logs:Describe*",
      "logs:TestMetricFilter",
      "logs:FilterLogEvents",
      "sns:Get*",
      "sns:List*"
    ]

    resources = [
      "*",
    ]
  }
  provider = aws.catalogue
}