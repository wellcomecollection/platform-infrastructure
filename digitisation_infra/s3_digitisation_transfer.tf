resource "aws_s3_bucket" "digitisation_transfer" {
  bucket = "wellcomecollection-digitisation-transfer"

  tags = local.default_tags
}
