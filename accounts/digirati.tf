# Roles

resource "aws_iam_role" "dds_access" {
  assume_role_policy = data.aws_iam_policy_document.dds_assume_role.json
}

data "aws_iam_policy_document" "dds_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.dds_principal_arn]
    }
  }
}
