resource "aws_s3_bucket" "working_storage" {
  bucket = "wellcomecollection-assets-workingstorage"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id = "transition_all_to_standard_ia"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    enabled = true
  }

  # To protect against accidental deletions, we enable versioning on this
  # bucket and expire non-current versions after 30 days.  This gives us an
  # additional safety net against mistakes.

  versioning {
    enabled = true
  }
  lifecycle_rule {
    id = "expire_noncurrent_versions"

    noncurrent_version_expiration {
      days = 30
    }

    enabled = true
  }
}

resource "aws_s3_bucket_policy" "working_storage" {
  bucket = aws_s3_bucket.working_storage.id
  policy = data.aws_iam_policy_document.working_storage.json
}

locals {
  digitisation_account_id = "404315009621"
  workflow_account_id     = "299497370133"
}


data "aws_iam_policy_document" "working_storage" {

  # These two statements allow the digitisation team to view the MIRO archive,
  # which is in s3://wc-assets-workingstorage/miro
  #
  # It also allows them to view the files that were saved from Preservica
  # for reingest through Goobi, in /preservica.
  statement {
    principals {
      identifiers = [
        "arn:aws:iam::${local.digitisation_account_id}:root",
        "arn:aws:iam::${local.workflow_account_id}:root",
      ]

      type = "AWS"
    }

    actions = [
      "s3:List*",
    ]

    resources = [
      aws_s3_bucket.working_storage.arn,
    ]
  }

  statement {
    principals {
      identifiers = [
        "arn:aws:iam::${local.digitisation_account_id}:root",
        "arn:aws:iam::${local.workflow_account_id}:root",
      ]

      type = "AWS"
    }

    actions = [
      "s3:Get*",
    ]

    resources = [
      "${aws_s3_bucket.working_storage.arn}/miro/*",
      "${aws_s3_bucket.working_storage.arn}/preservica/*",
    ]
  }
}
