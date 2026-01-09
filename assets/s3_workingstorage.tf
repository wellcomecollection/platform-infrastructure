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

    expiration {
      expired_object_delete_marker = true
    }

    enabled = true
  }

  # We lifecycle all the remaining Miro images to Glacier.  We aren't
  # going to look at these again until we move the Editorial Photography
  # images into the storage service.
  #
  # We were going to delete all of these, but this might cause us to lose
  # images -- we can't rely on "same ID" == "same image".  When we eventually
  # sort out the Editorial Photography images, we'll have to inspect these
  # images quite carefully to be sure we don't lose anything.
  #
  # In the meantime, putting them in Deep Archive will save us ~$1000 a year.
  #
  # See https://github.com/wellcomecollection/platform/issues/4885#issuecomment-816703253
  lifecycle_rule {
    id = "transition_miro_to_glacier"

    prefix = "miro/"

    transition {
      days          = 90
      storage_class = "DEEP_ARCHIVE"
    }

    enabled = true
  }

  tags = local.default_tags
}

resource "aws_s3_bucket_policy" "working_storage" {
  bucket = aws_s3_bucket.working_storage.id
  policy = data.aws_iam_policy_document.working_storage.json
}

locals {
  digitisation_account_id = "404315009621"
  workflow_account_id     = "299497370133"
  storage_account_id      = "975596993436"
}

data "aws_iam_policy_document" "working_storage" {
  statement {
    principals {
      identifiers = [
        "arn:aws:iam::${local.digitisation_account_id}:root",
        "arn:aws:iam::${local.workflow_account_id}:root",
        "arn:aws:iam::${local.storage_account_id}:root",
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
        "arn:aws:iam::${local.storage_account_id}:root",
      ]

      type = "AWS"
    }

    actions = [
      "s3:Get*",
    ]

    resources = [
      "${aws_s3_bucket.working_storage.arn}/preservica/*",
      "${aws_s3_bucket.working_storage.arn}/proquest/*",
      "${aws_s3_bucket.working_storage.arn}/av/*",
    ]
  }

  # Allow the digitisation team to upload objects into the "av" prefix.
  # See https://wellcome.slack.com/archives/C01B83N9NMP/p1631615772006800
  statement {
    principals {
      identifiers = [
        "arn:aws:iam::${local.digitisation_account_id}:root",
      ]

      type = "AWS"
    }

    actions = [
      "s3:Put*",
    ]

    resources = [
      "${aws_s3_bucket.working_storage.arn}/av/*",
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "working_storage" {
  bucket = "wellcomecollection-assets-workingstorage"

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}