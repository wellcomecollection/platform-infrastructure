# This user was created for the cataloguers to view the MIRO images kept
# in wellcomecollection-assets-workingstorage.  They use the access credentials
# to set up a "site" in FileZilla Pro, and browse the images there.
resource "aws_iam_user" "cataloguers_wellcome_images" {
  name = "cataloguers_wellcome_images"

  tags = local.default_tags
}

resource "aws_iam_access_key" "cataloguers_wellcome_images" {
  user = aws_iam_user.cataloguers_wellcome_images.name
}

data "aws_iam_policy_document" "allow_miro_access" {
  statement {
    actions = [
      "s3:List*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "s3:Get*",
    ]

    resources = [
      "arn:aws:s3:::wellcomecollection-storage/miro/*",
    ]
  }
}

resource "aws_iam_user_policy" "cataloguers_wellcome_images" {
  user   = aws_iam_user.cataloguers_wellcome_images.name
  policy = data.aws_iam_policy_document.allow_miro_access.json
}
