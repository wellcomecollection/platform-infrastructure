resource "aws_s3_bucket" "digitisation_av" {
  bucket = "wellcomecollection-digitisation-av"
}

resource "aws_s3_bucket_versioning" "digitisation_av" {
  bucket = aws_s3_bucket.digitisation_av.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "digitisation_av" {
  bucket = aws_s3_bucket.digitisation_av.id

  rule {
    id     = "Transition to Infrequent Access"
    status = "Enabled"

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
      aws_s3_bucket.digitisation_av.arn,
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
