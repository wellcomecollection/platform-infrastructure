resource "aws_s3_bucket" "client_transfer" {
  bucket = "wellcomecollection-client-transfer-pre2020"

  tags = local.default_tags
}

resource "aws_s3_bucket_policy" "client_transfer" {
  bucket = aws_s3_bucket.client_transfer.id
  policy = data.aws_iam_policy_document.client_transfer_readonly.json
}

data "aws_iam_policy_document" "client_transfer_readonly" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.client_transfer.arn}",
      "${aws_s3_bucket.client_transfer.arn}/*",
    ]

    principals {
      identifiers = [
        local.workflow_account_id,
      ]

      type = "AWS"
    }
  }
}
