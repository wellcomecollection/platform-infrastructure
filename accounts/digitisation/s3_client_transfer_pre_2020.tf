resource "aws_s3_bucket" "client_transfer_pre_2020" {
  bucket = "wellcomecollection-client-transfer-pre2020"
}

resource "aws_s3_bucket_policy" "client_transfer_pre_2020" {
  bucket = aws_s3_bucket.client_transfer_pre_2020.id
  policy = data.aws_iam_policy_document.client_transfer_pre_2020_readonly.json
}

data "aws_iam_policy_document" "client_transfer_pre_2020_readonly" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      aws_s3_bucket.client_transfer_pre_2020.arn,
      "${aws_s3_bucket.client_transfer_pre_2020.arn}/*",
    ]

    principals {
      identifiers = [
        local.account_ids["workflow"],
      ]

      type = "AWS"
    }
  }
}
