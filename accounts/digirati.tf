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

data "aws_iam_policy_document" "allow_intranda_export_bucket_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${local.intranda_export_bucket}",
      "arn:aws:s3:::${local.intranda_export_bucket}/*"
    ]
  }
}

data "aws_iam_policy_document" "allow_editorial_photography_goobi_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${aws_s3_bucket.editorial_photography.arn}",
      "${aws_s3_bucket.editorial_photography.arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        local.goobi_role_arn,
        local.itm_role_arn,
        local.shell_server_role_arn,
      ]
    }
  }
}
