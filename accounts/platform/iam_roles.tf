# Developer S3 Scala library access

resource "aws_iam_role" "s3_scala_releases_read" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [local.aws_principal]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role_policy" "s3_scala_releases_read" {
  policy = data.aws_iam_policy_document.s3_scala_releases_read.json
  role   = aws_iam_role.s3_scala_releases_read.name
}

data "aws_iam_policy_document" "s3_scala_releases_read" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/*",
    ]
  }
}
