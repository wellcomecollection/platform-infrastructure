resource "aws_s3_bucket" "delivery_service" {
  bucket = "wellcomecollection-delivery-service"
}

locals {
  workflow_account_id = "299497370133"
}

resource "aws_s3_bucket_policy" "delivery_service" {
  bucket = aws_s3_bucket.delivery_service.id
  policy = data.aws_iam_policy_document.delivery_service.json
}

data "aws_iam_policy_document" "delivery_service" {
  statement {
    principals {
      identifiers = [
        "arn:aws:iam::${local.workflow_account_id}:root",
      ]

      type = "AWS"
    }

    actions = [
      "s3:Put*",
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      aws_s3_bucket.delivery_service.arn,
      "${aws_s3_bucket.delivery_service.arn}/*",
    ]
  }
}
