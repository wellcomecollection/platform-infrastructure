resource "aws_s3_bucket" "client_transfer_bucket" {
  bucket = "wellcomecollection-client-transfer"
  acl    = "private"

  provider = aws.platform
}

resource "aws_s3_bucket_policy" "client_transfer_read_write" {
  bucket = aws_s3_bucket.client_transfer_bucket.id
  policy = data.aws_iam_policy_document.client_transfer_read_write.json

  provider = aws.platform
}

data "aws_iam_policy_document" "client_transfer_read_write" {
  statement {
    resources = [
      aws_s3_bucket.client_transfer_bucket.arn,
      "${aws_s3_bucket.client_transfer_bucket.arn}/*",
    ]

    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
      "s3:Delete*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        module.digitisation_account.developer_role_arn,
      ]
    }
  }
}
