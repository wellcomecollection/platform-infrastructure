# Wellcome - Digital production team

resource "aws_s3_bucket" "client_transfer_bucket" {
  bucket = "wellcomecollection-client-transfer"
  acl    = "private"
}