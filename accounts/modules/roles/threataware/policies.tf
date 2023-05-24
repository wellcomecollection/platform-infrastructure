data "aws_iam_policy_document" "allow_assume_threataware_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::856494794361:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["ta-app-assume-role"]
    }
  }
}

data "aws_iam_policy_document" "disable_s3_get_object" {
  statement {
    effect = "Deny"

    actions   = ["s3:GetObject"]
    resources = ["*"]
  }
}
