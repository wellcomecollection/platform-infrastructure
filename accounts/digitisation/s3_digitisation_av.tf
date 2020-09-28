resource "aws_s3_bucket" "digitisation_av" {
  bucket = "wellcomecollection-digitisation-av"

  lifecycle_rule {
    id      = "Transition to Infrequent Access"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}


resource "aws_s3_bucket_policy" "digitisation_av" {
  bucket = aws_s3_bucket.digitisation_av.id
  policy = data.aws_iam_policy_document.digitisation_av_readonly.json
}

data "aws_iam_policy_document" "digitisation_av_readonly" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.digitisation_av.arn}",
      "${aws_s3_bucket.digitisation_av.arn}/*",
    ]

    principals {
      identifiers = [
        local.account_ids["workflow"],
      ]

      type = "AWS"
    }
  }
}
